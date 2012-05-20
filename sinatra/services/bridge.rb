require 'yaml'
require 'time'
require 'services/notice'
require 'models/common/db'
require 'models/common/util'
require 'models/common/user'
require 'models/common/mail'
require 'models/service/amazon'
require 'models/service/jansearch'
require 'models/service/im'

module Tmarker
  class Bridge

    include Tmarker::Common::Util

    attr_reader :notice
    attr_writer :open, :blogparts_opt

    def initialize
      @notice  = Tmarker::Notice.instance
      @config  = YAML.load_file(config_path)
      @message = YAML.load_file(message_path)
      @amazon  = service_amazon
    end

    # set error message
    def service_notice_message(msg)
      @notice.message << msg
    end

    # check useragent
    def service_useragent(useragent)
      iphone?(useragent)
    end

    # check function name from URL
    def service_url(func)
      result = valid_func?(func)
      service_notice_message(@message["E000004"]) unless result
      result
    end

    # register data
    def service_register(data, table)
      result = false
      db = Tmarker::Common::DB.new(table)
      # recommendation
      if data.is_a?(Array)
        result = db.multi_insert(data)
      # item or wish
      else
        result = db.insert(data)
        unless result
          service_notice_message(@message["E000002"] % data[:jancode])
        end
      end
      result
    end

    # update item count
    def service_addition(data, table)
      db = Tmarker::Common::DB.new(table)
      result = db.update({:user_id => data[:user_id], :jancode => data[:jancode]},
        :register_date => Time.now, :item_count => data[:count] + 1)
      unless result
        service_notice_message(@message["E000009"] % data[:jancode])
      end
      result
    end

    # get item data
    def service_item(jancode, func)
      item = service_item_amazon(jancode)
      item = service_jansearch(jancode) if item.length == 0
      item = service_item_open(item) if item.length != 0 && func == 'item'
      item
    end

    # get item data from db
    def service_item_from_db(jancode, func)
      items = nil
      db = Tmarker::Common::DB.new(func)
      item = db.select({:jancode => jancode})
      item.each do |e| items = e end
      items
    end

    # item open/close setting
    def service_item_open(item)
      item[:open] = @open
      item
    end

    # get item count
    def service_item_count(user_id, jancode, table)
      count = 0
      db = Tmarker::Common::DB.new(table)
      item = db.select({:user_id => user_id, :jancode => jancode})
      item.each do |e|
        count = e[:item_count]
      end
      count
    end

    # delete wish data when item registered
    def service_wish_delete(user_id, jancode)
      db = Tmarker::Common::DB.new(:wishes)
      db.delete({:user_id => user_id, :jancode => jancode})
    end

    # get recommendation data
    def service_recommendation(jancode)
      recommendation_data = service_recommendation_amazon(jancode)
      service_register(recommendation_data, :recommendations)
    end

    # delete recommendation data when exists the data
    def service_recommendation_delete(jancode)
      result = true
      db = Tmarker::Common::DB.new(:recommendations)
      if db.select({:item_id => jancode}).count > 0
        result = db.delete({:item_id => jancode})
      end
      result
    end

    # get user data by apikey
    def service_user_by_apikey(apikey)
      service_user({:apikey => apikey})
    end

    # get user data by accesskey
    def service_user_by_accesskey(accesskey)
      service_user({:accesskey => accesskey})
    end

    # get user data
    def service_user(user_key)
      user = Tmarker::Common::User.new
      user_data = user.get_user(user_key)
      if user_data.nil?
        service_notice_message(@message["E000003"])
        [{}, nil]
      else
        user_data_for_item = {:user_id => user_data[:id], :register_date => Time.now}
        user_data_for_mail = {:user_name => user_data[:login], :mail => user_data[:email]}
        [user_data_for_item, user_data_for_mail]
      end
    end

    # send mail
    def service_mail(data)
      config = YAML.load_file(config_path)["mail"]
      f = open(root_path + '/template/item_mail.tmpl')
      message = f.read % [config["address"], data[:mail], Time.now.rfc2822,
        data[:item_title], data[:jancode], data[:user_name], config["address"]]

      # send
      mail = Tmarker::Common::Mail.new
      mail.send({
        :to => data[:mail],
        :message => message
      })
    end

    # output blogparts html
    def service_blogparts(user, opt)
      f = open(root_path + '/template/blogparts_frame.tmpl')
      db = Tmarker::Common::DB.new(opt[:func])
      where = {:user_id => user[:user_id]}.merge(opt[:cond])
      elem = db.select(where).limit(opt[:count]).order(:register_date.desc)

      content = elem.each_with_object [] do |e, r|
        c = open(root_path + '/template/blogparts_content.tmpl')
        image = e[:item_image_small] || url_for_rails + 'images/noimg-small.gif'
        link  = url_for_rails + 'detail/' + e[:jancode]
        r << c.read % [link, image, link, e[:item_title].gsub(/"/, "\"")]
      end

      header = @message[opt[:msg_code_i]] % user[:user_name]

      # item not found
      if content.length == 0
        service_notice_message(@message[opt[:msg_code_e]])
        service_blogparts_error(header)
      # item found
      else
        (f.read % [opt[:width], header, content.to_s]).split(/\n|\r\n/)
      end
    end

    # output blogparts html for item
    def service_blogparts_for_item(user, opt)
      opt.merge!({
        :cond => {:open => true},
        :msg_code_i => "I000003",
        :msg_code_e => "E000005"
      })
      service_blogparts(user, opt)
    end

    # output blogparts html for wish
    def service_blogparts_for_wish(user, opt)
      # get wish data
      opt.merge!({
        :cond => {},
        :msg_code_i => "I000004",
        :msg_code_e => "E000006"
      })
      service_blogparts(user, opt)
    end

    # output blogparts error html
    def service_blogparts_error(header = @message["E000007"])
      f = open(root_path + '/template/blogparts_frame.tmpl')
      e = open(root_path + '/template/blogparts_error.tmpl')
      content = @notice.message.uniq.join("<br/>")
      (f.read % [250, header, (e.read % content)]).split(/\n|\r\n/)
    end

    # parameter validation
    alias service_validate_func service_url

    def service_validate_width(n)
      result = Range.new(200, 350).include?(n.to_i)
      service_notice_message(@message["E000004"]) unless result
      result
    end

    def service_validate_count(n)
      result = Range.new(1, 5).include?(n.to_i)
      service_notice_message(@message["E000004"]) unless result
      result
    end

    # send instant message, register to items
    def service_im_items(item)
      service_im(item, @message["I000001"] % [item[:user_name], item[:item_title]])
    end

    # send instant message, register to wishes
    def service_im_wishes(item)
      service_im(item, @message["I000002"] % [item[:user_name], item[:item_title]])
    end

    # check allow site by referer
    def servive_allow_access?(user_id, referer)
      result = false
      db = Tmarker::Common::DB.new(:accesses)
      access = db.select({:user_id => user_id})
      access.each do |e|
        if url2hostname(referer) == e[:allow_host]
          result = true
          break
        end
      end
      service_notice_message(@message["E000008"])
      result
    end

    private

    # generate instance for amazon
    def service_amazon
      Tmarker::Service::Amazon.new({
        :key => @config["amazon"]["key"],
        :secret => @config["amazon"]["secret"]
      })
    end

    # get item data from amazon
    def service_item_amazon(jancode)
      @amazon.get_item(jancode)
    end

    # get recommendation data from amazon
    def service_recommendation_amazon(jancode)
      @amazon.get_recommendation(jancode)
    end

    # get item data from jancode_search
    def service_jansearch(jancode)
      jansearch = Tmarker::Service::JanSearch.new
      jansearch.get_item(jancode)
    end

    # send instant message
    def service_im(item, message)
      im = Tmarker::Service::IM.new({
        :username => @config["im"]["username"],
        :password => @config["im"]["password"],
        :sig => @config["im"]["sig"]
      })
      im.notify(message)
    end
  end
end