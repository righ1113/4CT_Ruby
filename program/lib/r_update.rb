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
      @n_live2, @live2 = update ring, nchar, ncodes, n_live, live
      # computes {\cal C}_{i+1} from {\cal C}_i, updates "live"
    end

    private

    def update(ring, nchar, ncodes, n_live, live)
      i = 0
      n_live_box = [n_live]
      # nlive1、liveに破壊的代入をおこなう
      while i.zero? || (update_sub ncodes, n_live_box, live)
        # stillreal()でliveに破壊的代入をおこなう
        testmatch ring, nchar, live
        # computes {\cal M}_{i+1} from {\cal M}_i, updates the bits of "real" */
        i += 1
      end
      [n_live_box[0], live]
      # p 7
    end

    def update_sub(_ncodes, _n_live_box, _live)
      false
    end

    def testmatch(_ring, _nchar, _live) = 0
  end
end
