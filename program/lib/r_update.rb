# frozen_string_literal: true

require '../lib/c_const'

# Update モジュール
module Update
  # UpdateR クラス
  class UpdateR
    include Const

    attr_reader :n_live2, :live2

    def initialize(g_conf, n_live, live)
      ring    = g_conf[0 + 1][1]                 # ring-size
      ncodes  = (Const::POWER[ring] + 1) / 2     # number of codes of colorings of R
      @real   = Array.new(Const::SIMATCHNUMBER[Const::MAXRING] / 8 + 2, 255)
      nchar   = Const::SIMATCHNUMBER[ring] / 8 + 1

      # computes {\cal M}_{i+1} from {\cal M}_i, updates the bits of "real"
      update ring, nchar, ncodes, n_live, live
      # computes {\cal C}_{i+1} from {\cal C}_i, updates "live"
    end

    private

    def update(_ring, _nchar, _ncodes, _n_live, _live)
      # let (nlive2, live2) =
      p 7
    end
  end
end
