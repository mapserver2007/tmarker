/**
 * tmarker - tm_common.js
 * url: http://tmarker.summer-lights.jp
 * version: 0.0.3
 * Copyright (c) 2009-2010 Ryuichi TANAKA.
 */

var Tmarker = function() {};

//const
Tmarker.prototype.message = function(key) {
  var messages = {
    const_delete_confirm: "買いたいものリストから削除します。",
    const_lock_confirm: "公開・非公開設定を切り替えます。",
    const_failure: "処理に失敗しました。管理者に問い合わせて下さい。"
  };
  return messages[key];
}

// コンストラクタ(サブクラスからのコール)
Tmarker.prototype.init = function() {};

// 変数のbind用メソッド
Tmarker.prototype.bind = function() {
  var str = arguments[0];
  for (var i = 1; i < arguments.length; i++) str = str.replace("%s", arguments[i]);
  return str;
};

//clearfixを自動挿入
Tmarker.prototype.clearfix = function() {
  return $("<div>").addClass("clearfix");
};

/**
 * Ajax用メソッド
 * @param url URL
 * @param params 送信データ
 * @param opt 送信オプション(リクエストパラメータ、レスポンスの型)
 * @param success_callback 受信後コールバック(成功の場合)
 * @param error_callback 受信後コールバック(失敗の場合)(任意)
 */
Tmarker.prototype.xhr = function(url, params, opt, success_callback, error_callback) {
  var self = this;
  function result(callback, response) {
    if (typeof(callback) == "function") {
      callback.call(this, response);
    }
    else {
      alert("xhr error!");
    }
  }
  $.ajax({
    type: opt.type,
    dataType: opt.dataType,
    data: params,
    cache: true,
    url: url,
    success: function(response){
      result(success_callback, response);
    },
    error: function(response){
      result(error_callback);
    }
  });
};