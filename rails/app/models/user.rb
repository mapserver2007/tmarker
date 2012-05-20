require 'digest/sha1'
require 'yaml'
require 'models/common/mail'
require 'models/common/util'
class User < ActiveRecord::Base
  include Tmarker::Common::Util
  has_many :items
  has_many :wishes

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :login, :with => /[0-9A-Za-z_\-]/
  validates_inclusion_of    :page_in_item, :in => 5..50
  validates_inclusion_of    :page_in_wish, :in => 5..50
  validates_inclusion_of    :profile_in_item, :qrcode_in_item,
    :category_count_in_item, :total_cost_in_item, :calendar_in_item, :in => [true, false]
  validates_inclusion_of    :category_count_in_wish, :calendar_in_wish, :in => [true, false]
  before_save :encrypt_password, :create_apikey, :create_accesskey, :result_confirm

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation
  attr_accessible :page_in_item, :profile_in_item, :qrcode_in_item,
    :category_count_in_item, :total_cost_in_item, :calendar_in_item
  attr_accessible :page_in_wish, :category_count_in_wish, :calendar_in_wish

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def result_confirm
    {:login => login, :email => email}
  end

  def send_mail
    config = YAML.load_file(config_path)["mail"]
    path = File.dirname(File.expand_path($PROGRAM_NAME))
    f = open(path + '/../sinatra/template/user_mail.tmpl')
    message = f.read % [config["address"], email, Time.now.rfc2822,
      login, email, apikey, config["address"]]

    # send
    mail = Tmarker::Common::Mail.new
    mail.send({
      :to => email,
      :message => message
    })
  end

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def create_apikey
    return if password.blank?
    self.apikey = create_key(10)
  end

  def create_accesskey
    return if password.blank?
    self.accesskey = create_key(8)
  end

  def create_key(n)
    key = ""
    source = ("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a
    n.times do key << source[rand(source.size)].to_s end
    key
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
