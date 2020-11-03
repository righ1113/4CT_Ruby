# frozen_string_literal: true

require 'minitest'

# Const モジュール
module Const
  # Const クラス
  class Const
    MAXVAL     = 12
    CARTVERT   = 5 * MAXVAL + 2 # domain of l_A, u_A, where A is an axle
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
