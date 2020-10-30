# frozen_string_literal: true

require '../lib/c_read_file'

# LibReduce モジュール
module LibReduce
  # LibReduce クラス
  class LibReduce
    include ReadFile

    MAXVAL     = 12
    CARTVERT   = 5 * MAXVAL + 2 # domain of l_A, u_A, where A is an axle
    MAXLEV     = 12             # max level of an input line + 1

    attr_accessor :r_axles

    def initialize
      # 好配置を読み込む
      GoodConfs.new

      @r_axles = {
        low: Array.new(MAXLEV + 1, Array.new(CARTVERT, 0)),
        upp: Array.new(MAXLEV + 1, Array.new(CARTVERT, 0)),
        lev: 0
      }
    end
  end
end
