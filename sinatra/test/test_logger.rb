#!/usr/bin/ruby
require 'common/util/log'

### 正常系
# インスタンスを取得
ins = Tmarker::Util::Log.instance

p ins.write("test error", "error")

### 異常系
# インスタンスを生成
# ins = Tmarker::Util::Logger.new

# ログ出力ディレクトリが間違っている場合
#path = "C:/dummy"
