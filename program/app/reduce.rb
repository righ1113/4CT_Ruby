# frozen_string_literal: true

# $ activesupport の gem をインストールする
# $ cd program/app
# $ ruby reduce.rb

require '../lib/c_const'
require '../lib/c_read_file'

# Reduce クラス
class Reduce
  include Const
  include ReadFile

  def self.reduce
    # GoodConfsR クラスのインスタンスを作る
    g_confs = GoodConfsR.new
    p g_confs.data[1][0][1] # => 122
  end

  def self.hoge() = 8
end

# メイン関数としたもの
__FILE__ == $PROGRAM_NAME && Reduce.reduce
