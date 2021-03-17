# frozen_string_literal: true

require '../lib/c_const'

# Angles モジュール
module Angles
  # Angles クラス
  class Angles
    include Const

    attr_reader :angle

    def initialize(_g_conf, _edgeno)
      @angle = Array.new(Const::EDGES) { Array.new(5, 0) }
    end
  end
end
