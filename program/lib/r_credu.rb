# frozen_string_literal: true

require '../lib/c_const'

# CRedu モジュール
module CRedu
  # CReduR クラス
  class CReduR
    include Const

    # attr_reader :n_live2, :live2

    def initialize(g_conf, _n_live, _live, _diffangle, _sameangle, _contract)
      # @type const Const::POWER: Array[Integer]
      # @type const Const::SIMATCHNUMBER: Array[Integer]
      # @type const Const::MAXRING: Integer
      ring     = g_conf[0 + 1][1]                 # ring-size
      _ncodes  = (Const::POWER[ring] + 1) / 2     # number of codes of colorings of R
      _real    = Array.new(Const::SIMATCHNUMBER[Const::MAXRING] / 8 + 2, 255)
      _nchar   = Const::SIMATCHNUMBER[ring] / 8 + 1

      p 'CReduR.'
    end

    private

    def update(_ring, _nchar, _ncodes, _real)
      true
    end
  end
end
