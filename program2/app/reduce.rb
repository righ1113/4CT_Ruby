# frozen_string_literal: true

# ・実行方法
# $ cd program2/app
# $ bundle exec ruby reduce.rb                        (130m??)

require '../lib/c_const'
require '../lib/c_read_file'
require '../lib/r_edgeno'
require '../lib/r_angles'
require '../lib/r_findlive'
require '../lib/r_dredu'
require '../lib/r_credu'
require 'egison'

include Egison

# Reduce クラス
class Reduce
  include Const
  include ReadFile
  include EdgeNo
  include Angles
  include Findlive
  include DRedu
  include CRedu

  def self.reduce
    g_confs = GoodConfsR.new
    # p g_confs.data[1][0][1] # => 122

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

  def self.c_d_reducible?(g_conf, i)
    # puts 'start c_d_reducible?()'
    # p g_conf[0][1]

    # 1. strip()
    edgeno = EdgeNo.new g_conf
    # p strip.edgeno[1]

    # 2. findangles()
    # "findangles" fills in the arrays "angle","diffangle","sameangle" and
    # "contract" from the input "graph". "angle" will be used to compute
    # which colourings of the ring edges extend to the configuration; the
    # others will not be used unless a contract is specified, and if so
    # they will be used in "checkcontract" below to verify that the
    # contract is correct. *)
    angles = Angles.new g_conf, edgeno.edgeno
    # p angles.angle[1]

    # 3. findlive()
    findlive = Findlive.new g_conf, angles.angle
    # p findlive.n_live

    # 4. update()
    dredu = DRedu.new g_conf, findlive.n_live, findlive.live

    # 5. checkContract()
    # This verifies that the set claimed to be a contract for the
    # configuration really is.
    if dredu.n_live.zero?
      if angles.contract[0].zero?
        # D可約 のときは、CRedu を作らない
      else
        Const.assert (1 == 2), true, '         ***  ERROR: CONTRACT PROPOSED  ***\n\n'
      end
    else
      CRedu.new g_conf, dredu.n_live, dredu.live, angles.diffangle, angles.sameangle, angles.contract
    end

    i != 19 # 633
  end
end

# メイン関数としたもの
__FILE__ == $PROGRAM_NAME && Reduce.reduce
