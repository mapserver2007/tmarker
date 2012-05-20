/**
 * tmarker - tm_item.js
 * url: http://tmarker.summer-lights.jp
 * version: 0.0.1
 * Copyright (c) 2009-2010 Ryuichi TANAKA.
 */

var Item = function() {this.init.apply(this, arguments);};

Item.prototype = new Tmarker();

// コンストラクタ
Item.prototype.init = function(items, action) {
  if (items !== undefined) {
    this.items = eval(items);
    if (action !== undefined){ this.action = action.name; }
    Tmarker.prototype.init.call(this);
  }
};

// バーコード処理
Item.prototype.barcode = function() {
  this.action === undefined ? this.barcode_by_item() : this.barcode_by_wish();
};

Item.prototype.barcode_by_item = function() {
  for (var i = 0; i < this.items.length; i++) {
    this.display_barcode(this.items[i].item.jancode,
        this.items[i].item.jancode, "ean13", {barWidth:1, barHeight:30});
  }
};

Item.prototype.barcode_by_wish = function() {
  for (var i = 0; i < this.items.length; i++) {
    this.display_barcode(this.items[i].wish.jancode,
        this.items[i].wish.jancode, "ean13", {barWidth:1, barHeight:30});
  }
};

Item.prototype.display_barcode = function(className, jancode, codename, opt) {
  $("." + className).barcode(jancode, codename, opt);
};