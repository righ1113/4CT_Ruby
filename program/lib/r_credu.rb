# frozen_string_literal: true

require '../lib/c_const'

# CRedu モジュール
module CRedu
  # CReduR クラス
  class CReduR
    include Const

    # attr_reader :n_live2, :live2

    def initialize(g_conf, n_live, live, diffangle, sameangle, contract)
      # @type const Assert: untyped
      # @type const Const::POWER: Array[Integer]
      # @type const Const::SIMATCHNUMBER: Array[Integer]
      # @type const Const::MAXRING: Integer
      # @type const Const::EDGES: Integer
      ring    = g_conf[0 + 1][1]                     # ring-size
      _ncodes = (Const::POWER[ring] + 1) / 2         # number of codes of colorings of R
      bigno   = (Const::POWER[ring + 1] - 1) / 2     # needed in "inlive"

      Assert.assert_equal (contract[0] != 0), true,                 '       ***  ERROR: NO CONTRACT PROPOSED  ***\n\n'
      Assert.assert_equal (n_live == contract[Const::EDGES]), true, ' ***  ERROR: DISCREPANCY IN EXTERIOR SIZE  ***\n\n'

      start     = diffangle[0][2]
      c         = Array.new(Const::EDGES, 0)
      forbidden = Array.new(Const::EDGES, 0) # called F in the notes
      start -= 1 while contract[start] != 0
      c[start] = 1
      j = start - 1
      j -= 1 while contract[j] != 0
      dm = diffangle[j]
      sm = sameangle[j]
      c[j], u = 1, 4
      imax1 = dm[0] >= 4 ? 4 : dm[0]
      (1..imax1).each { |i| u ||= c[dm[i]] }
      imax2 = sm[0] >= 4 ? 4 : sm[0]
      (1..imax2).each { |i| u ||= ~c[sm[i]] }
      forbidden[j] = u

      check_c_reduce forbidden, c, contract, j, start, diffangle, sameangle, bigno, ring, live

      p 'CReduR.'
    end

    private

    def check_c_reduce(_forbidden, _ccc, _contract, _jjj, _start, _diffangle, _sameangle, _bigno, _ring, _live)
      true
    end
  end
end
