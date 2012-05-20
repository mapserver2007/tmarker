#!/usr/bin/ruby

TMARKER_ROOT = File.dirname(File.expand_path($PROGRAM_NAME))

$: << TMARKER_ROOT
$: << TMARKER_ROOT + "/../../sinatra/"

require 'rubygems'
require "active_support"
require "enumerator"
require 'models/common/db'

module Tmarker
  class Ngram
    def sim(a, b, n, r = 0)
      agram = ngram(a, n)
      bgram = ngram(b, n)

      all  = (agram | bgram).size.to_f
      same = (agram & bgram).size.to_f

      (same / all).round(r)
    end

    private

    def ngram(str, n)
      ret = []
      str.split(//u).each_cons(n) do |a|
        ret << a.join
      end
      ret
    end
  end

  class Weight
    DECIMAL_POINT = 2
    attr_reader :title, :creator, :recommendation, :category
    attr_reader :distance

    def exec(i1, i2, r1, r2)
      # title
      @title = comp_similar(
        i1[:item_title], i2[:item_title], 2, DECIMAL_POINT
      )

      # creator
      @creator = comp_parallel(
        [i1[:author], i1[:creator], i1[:publisher]],
        [i2[:author], i2[:creator], i2[:publisher]],
        3,
        DECIMAL_POINT
      )

      # recommendation
      @recommendation = comp_cross(
        r1, r2, 5, DECIMAL_POINT
      )

      # cateogry
      @category = comp_parallel(
        [i1[:group_id]], [i2[:group_id]], 1
      )

      # distance
      @distance = calc_distance
    end

    def comp_similar(a, b, n, r = 0)
      ngram = Tmarker::Ngram.new
      ngram.sim(a, b, n, r)
    end

    def comp_parallel(a, b, n, r = 0)
      cnt = 0
      n.times do |idx|
        cnt += 1 if a[idx] == b[idx]
      end
      (cnt.to_f / n).round(r)
    end

    def comp_cross(a, b, n, r = 0)
      ((a & b).size.to_f / n).round(r)
    end

    def calc_distance
      # 重みはあとでDBか設定ファイル
      1 - (@title * 1 + @creator * 3 +
        @recommendation * 2 + @category * 4) / 10
    end
  end
end

# DBに接続
db_distance = Tmarker::Common::DB.new(:distances)
db_item = Tmarker::Common::DB.new(:items)
db_recommendation = Tmarker::Common::DB.new(:recommendations)

# 比較元の商品
base = db_item.select.group(:item_title).order(:id)

base.each do |eb|
  # 比較元のおすすめ商品
  base_r = db_recommendation.select({:item_id => eb[:jancode]})
  # おすすめ商品のJANコードを取得
  br = base_r.each_with_object [] do |e, r|
    r << e[:jancode]
  end

  # 比較先の商品
  target = db_item.select.group(:item_title).order(:id)

  target.each do |et|
    # 自分自身とは比較しない
    next if eb[:id] == et[:id]

    # すでに登録されている場合は比較しない
    count = db_distance.select({:base_id => eb[:id], :target_id => et[:id]}).count
    next if count != 0

    # 比較先のおすすめ商品
    target_r = db_recommendation.select({:item_id => et[:jancode]})
    tr = target_r.each_with_object [] do |e, r|
      r << e[:jancode]
    end

    # 各重みを取得
    weight = Tmarker::Weight.new
    weight.exec(eb, et, br, tr)

    # データを登録
    result = db_distance.insert({
      :base_id               => eb[:id],
      :target_id             => et[:id],
      :title_weight          => weight.title,
      :creator_weight        => weight.creator,
      :recommendation_weight => weight.recommendation,
      :category_weight       => weight.category,
      :distance              => weight.distance
    })

    if result
      puts "[OK]\tDistance of ID:#{eb[:id]} and ID:#{et[:id]} is #{weight.distance}"
    else
      puts "[NG]\tDistance calculation is failure."
    end
  end
end