require 'services/bridge'
require 'models/common/db'
require 'active_support'

module Tmarker
  class Base
    def initialize(params)
      @notice = Tmarker::Notice.instance
      @bridge = Tmarker::Bridge.new
      # UserAgent check
      @render = @bridge.service_useragent(params[:agent].to_s) ? :iphone : :pc
      # set jancode
      @jancode = params[:jancode]
      # set apikey
      @apikey = params[:apikey]
      # set accesskey
      @accesskey = params[:accesskey]
      # set referer
      @referer = params[:referer]
      # set function
      @func = params[:func]
      # set item open
      @bridge.open = open?
    end

    def push_to
      @func.pluralize.intern unless @func.nil?
    end

    alias pull_from push_to

    def authenticate?(key)
      if key.length == 10
        authenticate_by_apikey?(key)
      elsif key.length == 8
        authenticate_by_accesskey?(key)
      else
        authenticate_failure?
      end
    end

    def authenticate_by_apikey?(apikey)
      @user_data_for_item, @user_data_for_mail = @bridge.service_user_by_apikey(apikey)
      @user_data_for_item.length != 0
    end

    def authenticate_by_accesskey?(accesskey)
      @user_data_for_item, @user_data_for_mail = @bridge.service_user_by_accesskey(accesskey)
      unless @user_data_for_item.length == 0 || @user_data_for_mail.nil?
        @user_data = {
          :user_id   => @user_data_for_item[:user_id],
          :user_name => @user_data_for_mail[:user_name]
        }
        @bridge.servive_allow_access?(@user_data[:user_id], @referer)
      else
        false
      end
    end

    def authenticate_failure?
      @bridge.service_user(nil)
      false
    end

    def open?(open = nil)
      if open.nil?
        @func == 'item'
      else
        # TODO 外部からの公開・非公開設定を有効にする
        nil
      end
    end

    def success
      finalizer
      true
    end

    def error
      finalizer
      false
    end

    def finalizer
      # set error messages
      @message = @bridge.notice.message.uniq
      # init message in notice object
      @notice.finalizer
    end
  end

  class Main < Base
    attr_accessor :items, :message, :jancode, :user_name
    attr_accessor :render

    def initialize(params)
      super
    end

    def exec
      # function check
      return error unless @bridge.service_url(@func)
      # user authentication
      return error unless authenticate?(@apikey)

      # get user
      @user_id   = @user_data_for_item[:user_id]
      @user_name = @user_data_for_mail[:user_name]

      # already item register? (only item mode)
      if already_registered? && @func == 'item'
        # update item count
        return error unless @bridge.service_addition(
          {:user_id => @user_id, :jancode => @jancode, :count => @item_count}, push_to)

        # item data
        @items = @bridge.service_item_from_db(@jancode, pull_from)

        # merge hash (user and item)
        @items.merge!(@user_data_for_mail)

        # send im
        @bridge.service_im_items(@items)

        # delete data from wish
        @bridge.service_wish_delete(@user_id, @jancode)

        success
      # get item data?
      elsif yet_registered?
        # merge hash (user and item)
        @item_data.merge!(@user_data_for_item)
        return error unless @bridge.service_register(@item_data, push_to)

        # send mail for register result
        @item_data.merge!(@user_data_for_mail)
        @bridge.service_mail(@item_data)

        # get recommendation data
        @bridge.service_recommendation(@jancode)

        # send im
        if @func == 'item'
          @bridge.service_im_items(@item_data)
          # delete data from wish
          @bridge.service_wish_delete(@user_id, @jancode)
        elsif @func == 'wish'
          @bridge.service_im_wishes(@item_data)
        end

        # item data
        @items = @item_data

        success
      else
        error
      end
    end

    def yet_registered?
      @item_data = @bridge.service_item(@jancode, @func)
      @item_data.length != 0
    end

    def already_registered?
      @item_count = @bridge.service_item_count(@user_id, @jancode, pull_from)
      @item_count != 0
    end
  end

  class Delete < Base
    def initialize(params)
      super
    end

    def exec
      # user authentication
      return error unless authenticate?(@apikey)

      # delete data from wish
      db = Tmarker::Common::DB.new(:wishes)
      delete_wish = db.delete({:jancode => @jancode})

      # delete data from recommendation
      delete_reccomendation = @bridge.service_recommendation_delete(@jancode)

      delete_wish && delete_reccomendation
    end
  end

  class BlogParts < Base
    attr_reader :html

    def initialize(params, request)
      params[:referer] = request.referer
      @width = params[:width]
      @count = params[:count]
      super(params)
    end

    def exec
      begin
        # invalid func parameter
        raise unless @bridge.service_validate_func(@func)
        raise unless @bridge.service_validate_width(@width)
        raise unless @bridge.service_validate_count(@count)

        # user authentication failure
        raise unless authenticate?(@accesskey)

        # set valid blogparts parameter
        opt = {
          :func  => push_to,
          :width => @width,
          :count => @count
        }

        # user authentication success
        if @func == 'item'
          @html = @bridge.service_blogparts_for_item(@user_data, opt)
        elsif @func == 'wish'
          @html = @bridge.service_blogparts_for_wish(@user_data, opt)
        end
        success
      rescue
        # blogparts error
        @html = @bridge.service_blogparts_error
        error
      end
    end
  end
end