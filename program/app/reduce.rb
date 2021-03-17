# frozen_string_literal: true

# ・以下は1回だけおこなう
# $ gem install bundler
# $ cd program
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd program/app
# $ bundle exec ruby reduce.rb

require '../lib/c_const'
require '../lib/c_read_file'
require '../lib/r_strip'
require '../lib/r_angles'

# Reduce クラス
class Reduce
  include Const
  include ReadFile
  include Strip
  include Angles

  def self.reduce
    # GoodConfsR クラスのインスタンスを作る
    g_confs = GoodConfsR.new
    # p g_confs.data[1][0][1] # => 122

    Assert.assertions = 0

    ret = g_confs.data[0..4].each_with_index.all? do |g_conf, i|
      puts ''
      p i
      c_d_reducible? g_conf, i
    end
    if ret
      puts '633個の好配置は全て、Ｄ可約 or Ｃ可約です。'
    else
      puts '実装中です。'
    end
  end

  def self.c_d_reducible?(g_conf, iii)
    puts 'start c_d_reducible?()'
    p g_conf[0][1]

    # 1. strip()
    # Strip クラスのインスタンスを作る
    strip = Strip.new g_conf
    p strip.edgeno[1]

    # 2. findangles()
    # "findangles" fills in the arrays "angle","diffangle","sameangle" and
    # "contract" from the input "graph". "angle" will be used to compute
    # which colourings of the ring edges extend to the configuration; the
    # others will not be used unless a contract is specified, and if so
    # they will be used in "checkcontract" below to verify that the
    # contract is correct. *)
    angles = Angles.new g_conf, strip.edgeno
    p angles.angle[1]

    # 3. findlive()

    # 4. update()

    # 5. checkContract()
    # This verifies that the set claimed to be a contract for the
    # configuration really is.

    iii != 4
  end
end

# メイン関数としたもの
__FILE__ == $PROGRAM_NAME && Reduce.reduce
