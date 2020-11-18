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
