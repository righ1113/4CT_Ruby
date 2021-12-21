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
      @n_live2, @live2 = n_live, live
      update ring, nchar, ncodes
      # computes {\cal C}_{i+1} from {\cal C}_i, updates "live"
    end

    private

    def update(ring, nchar, ncodes)
      i = 0
      # nlive1、liveに破壊的代入をおこなう
      while i.zero? || (update_sub ncodes)
        # stillreal()でliveに破壊的代入をおこなう
        testmatch ring, nchar
        # computes {\cal M}_{i+1} from {\cal M}_i, updates the bits of "real" */
        i += 1
      end
      true
    end

    def update_sub(ncodes)
      # runs through "live" to see which colourings still have `real' signed
      # matchings sitting on all three pairs of colour classes, and updates "live"
      # accordingly; returns 1 if nlive got smaller and stayed >0, and 0 otherwise *)

      new_n_live = 0
      @live2[0] = 15 if @live2[0] > 1

      ncodes.times do |i|
        if @live2[i] != 15
          @live2[i] = 0
        else
          new_n_live += 1
          @live2[i] = 1
        end
      end

      if new_n_live < @n_live2 && new_n_live.positive?
        @n_live2 = new_n_live
        true
      else
        if new_n_live.zero?
          print "\n\n\n                  ***  D-reducible  ***\n"
        else
          print "\n\n\n                ***  Not D-reducible  ***"
        end
        @n_live2 = new_n_live
        false
      end
    end

    def testmatch(_ring, _nchar)
      p 7
      0
    end
  end
end
