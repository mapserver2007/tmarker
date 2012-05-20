require 'rubygems'
require 'open-uri'
require 'date'
require 'hpricot'
require 'timeout'
require 'models/service/item'

module Tmarker
  module Service
    class JanSearch
      include Tmarker::Service::Item
      URL = 'http://www.janken.jp'
      TIMEOUT = 10

      def initialize
        super
        @url = "#{URL}/goods/jk_catalog_syosai.php?jan=%s"
      end

      def get_item(jancode)
        return [] unless jancode?(jancode)
        html = timeout(TIMEOUT) do Hpricot(open(@url % jancode).read) end
        item = {}
        begin
          p html.search("//td[@class='goodsval']")[4].inner_text.gsub(/\\/, '')
          item[:item_title]       = html.search("//h5[@id='gname']").inner_text.toutf8
          item[:item_price]       = html.search("//td[@class='goodsval']")[4].inner_text.gsub(/\\/, '')
          item[:author]           = nil
          item[:creator]          = nil
          item[:publisher]        = html.search("//td[@class='goodsval']")[2].inner_text.toutf8
          item[:isbn]             = nil
          item[:release_date]     = nil
          item[:publication_date] = nil
          item[:item_image_small] = html.search("//table[2]/tr[2]/td[3]").to_s.scan(/http?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+/)[0]
          item[:item_image_large] = nil
          item[:item_link]        = html.search("//td[@class='goodsval']")[8].to_s.scan(/http?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+/)[0]
          item[:item_price]       = nil if item[:item_price].empty?
          item[:item_image_small] = nil if ignore_image?(item[:item_image_small])
          item[:jancode]          = jancode
          @logger.write(item.values.join(","), "info")
        rescue
          item = {}
          @logger.write("item get failure.", "error")
        end
        if (item.length == 0)
          unget_item(jancode)
        else
          ds = @db.select({:product_group => 'Other'})
          ds.each do |grp| item[:group_id] = grp[:id] end
          item
        end
      end

      private

      def ignore_image?(path)
        ignore_path = 'http://www.janken.jp/img/no_image150.jpg'
        path == ignore_path
      end
    end
  end
end
