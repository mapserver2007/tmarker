#!/usr/bin/ruby

TMARKER_ROOT = File.dirname(File.expand_path($PROGRAM_NAME))
$: << TMARKER_ROOT + "/../../sinatra/"

require 'rubygems'
require 'active_support'
require 'open-uri'
require 'rexml/document'
require 'models/common/log'
require 'models/common/db'

module Tmarker
  module History
    URL = {
      'svn' => 'http://redmine.summer-lights.jp/projects/tmarker/repository/revisions.atom',
      'dev' => 'http://redmine.summer-lights.jp/projects/tmarker/issues.atom?query_id=1'
    }
    class Rss
      def initialize
        @logger = Tmarker::Common::Log.instance
      end

      def get(atom_name)
        return get_svn if atom_name == :development_logs
        return get_dev if atom_name == :tracking_logs
      end

      private

      def get_svn
        xml = xml_parse(URL['svn'])
        xml.elements['//feed'].each_with_object [] do |e, r|
          begin
            r << {
              :log_id => e.elements['id'].text.split(/\//).reverse[0],
              :title  => e.elements['title'].text.gsub(/.*?:/, '').strip,
              :link   => e.elements['id'].text,
              :date   => e.elements['updated'].text
            }
          rescue
            next
          end
        end.reverse unless xml.nil?
      end

      def get_dev
        xml = xml_parse(URL['dev'])
        xml.elements['//feed'].each_with_object [] do |e, r|
          begin
            if e.elements['title'].text =~ /(.*?)#(\d*)(.*?):(.*?)$/
              r << {
                :log_id  => $2,
                :title   => $4,
                :link    => e.elements['id'].text,
                :tracker => $1,
                :status  => $3.gsub(/\(|\)/, '').strip,
                :date    => e.elements['updated'].text,
                :content => e.elements['content'].text.strip
              }
            end
          rescue => e
            next
          end
        end.reverse unless xml.nil?
      end

      def xml_parse(url)
        begin
          open(url) do |f|
            return REXML::Document.new(f.read)
          end
        rescue OpenURI::HTTPError => e
          @logger.write(e, "error")
          return nil
        end
      end
    end
  end
end

[:development_logs, :tracking_logs].each do |mode|
  ## Atomから履歴を取得
  history = Tmarker::History::Rss.new
  data = history.get(mode)

  ## DBから登録済み履歴を取得
  db = Tmarker::Common::DB.new(mode)
  registered_db = db.select
  registered_data = registered_db.each_with_object [] do |e, r| r << e[:log_id] end

  puts "[START]\t#{mode.to_s}"

  begin
    unless data.nil?
      data.each do |e|
        # 登録済みでないければDBに追加する
        if registered_data.index(e[:log_id].to_i).nil?
          puts "[OK][INSERT]\t#{e[:link]}" if db.insert(e)
        # 登録済みであればDBを更新する
        else
          puts "[OK][UPDATE]\t#{e[:link]}" if db.update({:log_id => e[:log_id]}, e)
        end
      end
    end
  rescue => e
    puts e.to_s
  end
  puts "[END]\t#{mode.to_s}"
end