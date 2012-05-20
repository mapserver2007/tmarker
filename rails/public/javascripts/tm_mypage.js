/**
 * tmarker - tm_mypage.js
 * url: http://tmarker.summer-lights.jp
 * version: 0.0.3
 * Copyright (c) 2009-2010 Ryuichi TANAKA.
 */

var MyPage = function() {this.init.apply(this, arguments);};

MyPage.prototype = new Tmarker();

// コンストラクタ
MyPage.prototype.init = function(action) {
  if (action !== undefined){ this.action = action.name; }
};

// const
MyPage.prototype.image = function(key) {
  var images = {
    open:  "/images/icon-unlock.png",
    close: "/images/icon-lock.gif"
  };
  return images[key];
};

// メニューバー：カテゴリで絞り込み
MyPage.prototype.sort_category = function(list) {
  var url = '/my/' + list.user.id;
  if (this.action !== undefined) { url += '/' + this.action; }
  url += '/category/';
  var box = $("<div>").addClass("tranceparency_box");
  for (var i = 0; i < list.category.length; i++) {
    $("<p>").append($("<a>").attr("href", url + list.category[i].name)
      .html(list.category[i].name)).appendTo(box);
  }
  $("#sort_category").append(box)
    .mouseover(function(e){
      $("#sort_category > div").css({"display": "block", "left": "0px"});
    })
    .mouseout(function(e){
      $("#sort_category > div").css({"display": "none"});
    });
};

// メニューバー：値段で絞り込み
MyPage.prototype.sort_price = function(list) {
  var box = $("<div>").addClass("tranceparency_box");
  var url = '/my/' + list.user.id;
  if (this.action !== undefined) { url += '/' + this.action; }
  for (var i = 0; i < list.price.length; i++) {
    var request = "/price";
    for (var key in list.price[i]) {
      if (list.price[i][key][0]) {
        request += "/l/" + list.price[i][key][0];
      }
      if (list.price[i][key][1]) {
        request += "/h/" + list.price[i][key][1];
       }
     }
    $("<p>").append($("<a>").attr("href", url + request).html(key)).appendTo(box);
  }
  $("#sort_price").append(box)
    .mouseover(function(e){
      $("#sort_price > div").css({"display": "block", "left": "123px"});
    })
    .mouseout(function(e){
      $("#sort_price > div").css({"display": "none"});
    });
};

// サイドバー：購入金額合計
MyPage.prototype.total_cost = function(id, cost) {
  var width = cost.max == 0 ? 0 : Math.round((cost.price / cost.max) * 100);
  $("#" + id).css({"width": width + "%"});
};

// 商品一覧：買いたいものリストから削除
MyPage.prototype.delete_wish = function(params) {
  var url = "/my/%s/delete_wish";
  var bind_url = Tmarker.prototype.bind.apply(this, [url, params["user_id"]]);
  if (window.confirm(Tmarker.prototype.message.call(this, "const_delete_confirm"))) {
    var param = {jancode: params["jancode"]};
    var opt = {type: "get", dataType: "json"};
    Tmarker.prototype.xhr(
        bind_url,
        param,
        opt,
        MyPage.prototype.delete_success
    );
  }
};

// 商品一覧：公開・非公開設定
MyPage.prototype.lock_item = function(params) {
  var url = "/my/%s/lock_item";
  var bind_url = Tmarker.prototype.bind.apply(this, [url, params["user_id"]]);
  if (window.confirm(Tmarker.prototype.message.call(this, "const_lock_confirm"))) {
    var param = {jancode: params["jancode"]};
    var opt = {type: "get", dataType: "json"};
    Tmarker.prototype.xhr(
        bind_url,
        param,
        opt,
        MyPage.prototype.lock_success
    );
  }
};

// 商品一覧：買いたいものリストから削除後のコールバックが成功
MyPage.prototype.delete_success = function(res) {
  if (res.result) {
    $("#" + res.id).hide("highlight", null, 500, function(){
      $("#" + res.id).parent().remove();
    });
  }
  else {
    alert(Tmarker.prototype.message.call(this, "const_failure"));
  }
};

//商品一覧：公開・非公開設定ののコールバックが成功
MyPage.prototype.lock_success = function(res) {
  var self = this.mypage;
  if (res.result) {
    var key = res.open ? "open" : "close";
    $("#" + res.id).toggleClass("item_open", res.open);
    $("#" + res.id).toggleClass("item_close", !res.open);
    $("#" + res.id + " input")[0].src = self.image(key);
//    var key = res.open ? "open_item" : "close_item";
//    var color = res.open ? res.open : "#FFFFCC";
//    $("#" + res.id).css({"background-color": self.color(key)});
//    $("#" + res.id + " input")[0].src = self.image(key);
  }
  else {
    alert(Tmarker.prototype.message.call(this, "const_failure"));
  }
};
