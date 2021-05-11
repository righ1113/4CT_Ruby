# frozen_string_literal: true

require '../lib/c_const'

# Findlive モジュール
module Findlive
  # Findlive クラス
  class Findlive
    include Const

    attr_reader :n_live, :live

    def initialize(g_conf)
      ring    = g_conf[0 + 1][1]                 # ring-size
      ncodes  = (Const::POWER[ring] + 1) / 2     # number of codes of colorings of R
      bigno   = (Const::POWER[ring + 1] - 1) / 2 # needed in "inlive"
      @live   = Array.new(ncodes, 1)
      real0   = Array.new(Const::SIMATCHNUMBER[Const::MAXRING] / 8 + 2, 255)
      nchar   = Const::SIMATCHNUMBER[ring] / 8 + 1

      @n_live = 7
    end
  end
end
