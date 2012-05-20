class Setting < ActiveRecord::Base
  CONFIG_PATH = "#{RAILS_ROOT}/config/"
  @@tmarker_settings = YAML.load_file("#{CONFIG_PATH}/tmarker.yml")
  @@rss_settings     = YAML.load_file("#{CONFIG_PATH}/feed.yml")

  def self.config(key, file)
    YAML.load_file(CONFIG_PATH + file)[key]
  end

  def self.read_config(key)
    @@tmarker_settings[key]
  end

  def self.read_feed_config
    @@rss_settings
  end

  def self.title(sub_title = nil)
    t = read_config('application_name')
    sub_title.nil? ? t : t << " - #{sub_title}"
  end
end
