require 'open-uri'

class Mypage < ActiveRecord::Base
  cattr_accessor :current_user

  # 値段の範囲をバリデーション
  def self.price?(price)
    result = false
    price_list = self.price_list
    price_list.each do |e|
      e.each do |name, value|
        if value[0] == price[:low] && value[1] == price[:high]
          result = true
        end
      end
    end
    result
  end

  # メニューバー：カテゴリで絞り込み
  def self.category_list
    Item.scoped_category_list(current_user)
  end

  # メニューバー：値段で絞り込み
  def self.price_list
    prices = Setting.read_config("price_list")
    prices.each_with_object [] do |e, r|
      r << {e["price_label"] => e["price_range"].gsub(/\s/, '').split(/,/)}
    end
  end

  # サイドバー：プロフィール
  def self.profile
    User.find_by_login(current_user)
  end

  # サイドバー：QRコード
  def self.qrcode(param)
    # 埋め込むデータ取得
    e = profile

    # データエンコード
    encoded_data = [e[:login], e[:email], e[:apikey]].join("%0D%0A")

    # リクエストパラメータ生成
    req_param = []
    {
      :chs  => "#{param[:size]}x#{param[:size]}",
      :choe => param[:charset],
      :cht  => "qr",
      :chl  => encoded_data
    }.each do |k, v| req_param << "#{k}=#{v}" end

    # QRコードを取得
    begin
      open("http://chart.apis.google.com/chart?%s" % req_param.join("&")) do |f|
        return f.read
      end
    rescue OpenURI::HTTPError
      return nil
    end
  end

  # サイドバー：QRコード読み込み失敗時
  def self.qrcode_failure(path)
    begin
      f = open("#{RAILS_ROOT}/public#{path}")
      return f.binmode.read
    rescue OpenURI::HTTPError
      return nil
    end
  end

  # サイドバー：カテゴリ別登録数
  def self.category_count(model)
    table_nname = model.pluralize
    Group.scoped_category_count(current_user, table_nname)
  end

  # サイドバー：購入金額合計
  def self.total_costs
    costs = Setting.read_config("total_costs")
    costs.each_with_object [] do |e, r|
      r << {e["total_cost_label"], total_cost(e["total_cost_name"].intern)}
    end
  end

  # サイドバー：カレンダー
  def self.calendar(date, action_name)
    # Model名の取得
    model = eval(action_name.gsub(/^./) {|e| e.upcase })
    # カレンダー変数の設定
    #data = data.
    cal_data, day_count, regs = [], 1, []
    t = date.nil? ? Time.now.beginning_of_month : Time.local(date[0], date[1], date[3])
    # 月の日数＋カレンダーの月初めより前の空白分を加算
    day_of_first_month = t.to_a[6]
    day_of_last_month = t.end_of_month.to_a[3] + day_of_first_month
    # さらにカレンダーの月終わり以降の空白分を加算
    roop = day_of_last_month + (7 - day_of_last_month % 7)
    roop.times do |i|
      if (i >= day_of_first_month && i < day_of_last_month)
        cal_data.push(day_count)
        day_count += 1
      else
        cal_data.push("")
      end
    end
    # 登録されている日付を取得
    register_data = model.scoped_calendar_by_register_date(current_user, t, t.next_month)
    register_data.each do |d| regs << d end
    {:cal => cal_data, :reg => regs, :month => t}
  end

  private

  def self.total_cost(term)
    date = nil
    case term
      when :day
        date = Time.now.at_beginning_of_day
      when :week
        date = Time.now.at_beginning_of_week
      when :month
        date = Time.now.at_beginning_of_month
      when :year
        date = Time.now.at_beginning_of_year
    end
    price = Item.scoped_total_cost_by_date(current_user, date)
    total_cost_range(price[0].total_cost.to_i) unless price.nil?
  end

  def self.total_cost_range(price)
    place = 1
    price.size.times do place *= 10 end
    {
      :min => 0,
      :max => (price.prec_f / place).ceil * place,
      :price => price
    }
  end
end
