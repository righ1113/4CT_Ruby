# frozen_string_literal: true

require 'minitest'

# Const モジュール
module Const
  # Const クラス
  class Const
    MAXVAL     = 12
    CARTVERT   = 5 * MAXVAL + 2 # domain of l_A, u_A, where A is an axle
    INFTY      = 12             # the "12" in the definition of limited part
    MAXOUTLETS = 110            # max number of outlets
    MAXSYM     = 50             # max number of symmetries
    MAXELIST   = 134            # length of edgelist[a][b]
    MAXASTACK  = 5              # max height of Astack (see "Reduce")
    MAXLEV     = 12             # max level of an input line + 1

    MVERTS     = 27             # max number of vertices in a free completion + 1
    EDGES      = 62             # max number of edges in a free completion + 1
    MAXRING    = 14             # max ring-size # 3^(i-1)
    POWER =
      [0, 1, 3, 9, 27, 81, 243, 729, 2187, 6561,
       19_683, 59_049, 177_147, 531_441, 1_594_323, 4_782_969, 14_348_907].freeze
    SIMATCHNUMBER =
      [0, 0, 1, 3, 10, 30, 95, 301, 980, 3228, 10_797, 36_487, 124_542, 428_506, 1_485_003].freeze
  end

  # Assert クラス
  class Assert < Minitest::Test
    class << self
      # このモジュールの中に各種assertが定義されているのでinclude
      include Minitest::Assertions

      attr_accessor :assertions
    end
  end
end
