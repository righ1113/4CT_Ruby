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
require '../lib/r_findlive'
require '../lib/r_update'
require '../lib/r_credu'

# Reduce クラス
class Reduce
  include Const
  include ReadFile
  include Strip
  include Angles
  include Findlive
  include Update
  include CRedu

  def self.reduce
    # @type const Assert: untyped
    g_confs = GoodConfsR.new
    # p g_confs.data[1][0][1] # => 122

    Assert.assertions = 0

    # return if (data = g_confs.data[0..4]).nil?
    ret = g_confs.data.each_with_index.all? do |g_conf, i|
      # puts ''
      p i
      # next true if i == 7
      c_d_reducible? g_conf, i
    end
    if ret
      puts '633個の好配置は全て、Ｄ可約 or Ｃ可約です。'
    else
      puts '実装中です。'
    end
  end

  def self.c_d_reducible?(g_conf, iii)
    # @type const UpdateR: untyped
    # @type const CReduR: untyped
    # @type const Assert: untyped
    # puts 'start c_d_reducible?()'
    # p g_conf[0][1]

    # 1. strip()
    strip = StripR.new g_conf
    # p strip.edgeno[1]

    # 2. findangles()
    # "findangles" fills in the arrays "angle","diffangle","sameangle" and
    # "contract" from the input "graph". "angle" will be used to compute
    # which colourings of the ring edges extend to the configuration; the
    # others will not be used unless a contract is specified, and if so
    # they will be used in "checkcontract" below to verify that the
    # contract is correct. *)
    angles = AnglesR.new g_conf, strip.edgeno
    # p angles.angle[1]

    # 3. findlive()
    findlive = FindliveR.new g_conf, angles.angle
    # p findlive.n_live

    # 4. update()
    update = UpdateR.new g_conf, findlive.n_live, findlive.live

    # 5. checkContract()
    # This verifies that the set claimed to be a contract for the
    # configuration really is.
    if update.n_live2.zero?
      if angles.contract[0].zero?
        # D可約 のときは、CReduR を作らない
      else
        Assert.assert_equal (1 == 2), true, '         ***  ERROR: CONTRACT PROPOSED  ***\n\n'
      end
    else
      CReduR.new g_conf, update.n_live2, update.live2, angles.diffangle, angles.sameangle, angles.contract
    end

    iii != 24
  end
end

# メイン関数としたもの
__FILE__ == $PROGRAM_NAME && Reduce.reduce
