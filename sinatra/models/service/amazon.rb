require 'yaml'
require 'cgi'
require 'openssl'
require 'base64'
require 'digest/sha2'
require 'time'
require 'open-uri'
require 'rexml/document'
require 'active_support'
require 'models/common/util'
require 'models/service/item'

module Tmarker
  module Service
    class Amazon

      include Tmarker::Common::Util
      include Tmarker::Service::Item

      def initialize(params)
        super
        @key = params[:key]
        @secret = params[:secret]
        @host = 'webservices.amazon.co.jp'
        @path = '/onca/xml'
      end

      def get_item(code)
        # Validate jancode, asin
        if !jancode?(code) && !asin?(code)
          return unget_item(code)
        end
        # Get item xml
        @xml = amazon_xml(code)
        # Create item data
        item = {
          :item_title        => get_elem('//ItemAttributes/Title'),
          :item_price        => get_elem('//ItemAttributes/ListPrice/Amount'),
          :author            => get_elem('//ItemAttributes/Author'),
          :creator           => get_elem('//ItemAttributes/Creator'),
          :publisher         => get_elem('//ItemAttributes/Publisher'),
          :isbn              => get_elem('//ItemAttributes/ISBN'),
          :jancode           => get_elem('//ItemAttributes/EAN'),
          :release_date      => fixed_date(get_elem('//ItemAttributes/ReleaseDate')),
          :publication_date  => fixed_date(get_elem('//ItemAttributes/PublicationDate')),
          :item_image_small  => get_elem('//ImageSets/ImageSet/SmallImage/URL'),
          :item_image_medium => get_elem('//ImageSets/ImageSet/MediumImage/URL'),
          :item_image_large  => get_elem('//ImageSets/ImageSet/LargeImage/URL'),
          :item_link         => get_elem('//DetailPageURL')
        }
        ds = @db.select({:product_group => get_elem('//ItemAttributes/ProductGroup')})
        ds.each do |grp|
          item[:group_id] = grp[:id]
          return item
        end
        # Item notfound
        unget_item(code)
      end

      def get_recommendation(code)
        # Validate jancode
        jancode = nil
        if jancode?(code)
          jancode = code
        elsif asin?(code)
          jancode = asin2jancode(code)
        else
          return unget_item(code)
        end
        # Create recommendation data
        rec_elem = @xml.elements['//SimilarProducts'] || []
        recomendations = rec_elem.each_with_object [] do |e, r|
          recommendation_jancode = asin2jancode(e.elements['ASIN'].text)
          recommendation_item = get_item(recommendation_jancode)
          r << {
            :item_id => jancode,
            :item_title => e.elements['Title'].text,
            :item_image_small => recommendation_item[:item_image_small],
            :item_link => recommendation_item[:item_link],
            :release_date => recommendation_item[:release_date] || recommendation_item[:publication_date],
            :jancode => recommendation_jancode
          }
        end
        recomendations.length == 0 ? [] : recomendations
      end

      private

      def get_elem(xpath)
        item = nil
        begin
          item = @xml.elements[xpath].text
        rescue NoMethodError
          item = nil
        end
        item
      end

      def asin2jancode(code)
        xml = amazon_xml(code)
        xml.elements['//ItemAttributes/EAN'].text
      end

      def create_url(keyword)
        # Define request parameter
        param = {
          "Service" => "AWSECommerceService",
          "AWSAccessKeyId" => @key,
          "Operation" => "ItemSearch",
          "SearchIndex" => "All",
          "Keywords" => keyword,
          "ResponseGroup" => "Images,ItemAttributes,Similarities",
          "Timestamp" => Time.now.getutc.iso8601,
          "Version" => "2009-03-31"
        }
        # Create request parameter, signeture
        query = param.sort_by{|k, v| k}.map{|k, v| "#{k}=#{CGI.escape(v)}"}.join("&")
        message = ['GET', @host, @path, query].join("\n")
        dig = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, @secret, message)
        sig = CGI.escape(Base64.encode64(dig).chomp)
        # Create Amazon URL
        "http://#{@host}#{@path}?#{query}&Signature=#{sig}"
      end

      def amazon_xml(jancode)
        begin
          open(create_url(jancode)) do |f|
            # XML Element
            return REXML::Document.new(f.read)
          end
        rescue OpenURI::HTTPError => e
          @logger.write(e, "error")
        end
      end

    end
  end
end