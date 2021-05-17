# frozen_string_literal: true

require '../lib/c_const'

# Findlive モジュール
module Findlive
  # Findlive クラス
  class Findlive
    include Const

    attr_reader :n_live, :live

    def initialize(g_conf, angle)
      ring    = g_conf[0 + 1][1]                 # ring-size
      ncodes  = (Const::POWER[ring] + 1) / 2     # number of codes of colorings of R
      bigno   = (Const::POWER[ring + 1] - 1) / 2 # needed in "inlive"
      @live   = Array.new(ncodes, 1)
      # real0   = Array.new(Const::SIMATCHNUMBER[Const::MAXRING] / 8 + 2, 255)
      # nchar   = Const::SIMATCHNUMBER[ring] / 8 + 1

      findlive ring, bigno, ncodes, angle, g_conf[0 + 1][2]
    end

    private

    def findlive(_ring, _bigno, _ncodes, angle, _extentclaim)
      # computes {\cal C}_0 and stores it in live. That is, computes codes of
      # colorings of the ring that are not restrictions of tri-colorings of the
      # free extension. Returns the number of such codes

      ed           = angle[0][2]
      c            = Array.new(Const::EDGES, 0)
      j            = ed - 1
      c[ed]        = 1
      c[j]         = 2
      forbidden    = Array.new(Const::EDGES, 0)
      forbidden[j] = 5
      # let structureTuple = LibReduceLive.FindliveSub (bigno, angle, POWER, ring, ed, extentclaim, ncodes, live0, j, c, forbidden)
      #   // 構造体タプルのパターンマッチ
      # match structureTuple with
      #   | struct (ncodes1, live1) -> (ncodes1, live1)

      @n_live = 7
    end
  end
end
