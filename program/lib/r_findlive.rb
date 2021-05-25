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

    def findlive(ring, bigno, ncodes, angle, extentclaim)
      # computes {\cal C}_0 and stores it in live. That is, computes codes of
      # colorings of the ring that are not restrictions of tri-colorings of the
      # free extension. Returns the number of such codes

      ed             = angle[0][2]
      c              = Array.new(Const::EDGES, 0)
      j              = ed - 1
      c[ed]          = 1
      c[j]           = 2
      forbidden      = Array.new(Const::EDGES, 0)
      forbidden[j]   = 5
      @n_live, @live = findlive_sub bigno, angle, ring, ed, extentclaim, ncodes, j, c, forbidden
    end

    def findlive_sub(bigno, angle, ring, edd, extentclaim, ncodes, jjj, ccc, forbidden)
      262_144.times do
        while (forbidden[jjj] & ccc[jjj]) != 0
          ccc[jjj] <<= 1
          while (ccc[jjj] & 8) != 0
            if j >= ed - 1
              # Printstatus(ring, ncodes, extent, extentclaim);
              return [ncodes - extent, @live]
            end
            ccc[jjj] <<= 1
          end
        end
        #   if (j == ring + 1) {
        #     extent = Record(c, power, ring, angle, live, extent, bigno);
        #     c[j] <<= 1;
        #     while ((c[j] & 8) != 0) {
        #       if (j >= ed - 1) {
        #           Printstatus(ring, ncodes, extent, extentclaim);
        #           return ((ncodes - extent), live);
        #       }
        #       c[++j] <<= 1;
        #     }
        #   }
        #   else {
        #     --j;
        #     if (j < 0) {
        #         return ((ncodes - extent), live);
        #     }
        #     c[j] = 1;
        #     for (u = 0, i = 1; i <= angle[j][0]; i++) {
        #       if (i >= 5) break;
        #       u |= c[angle[j][i]];
        #     }
        #     forbidden[j] = u;
        #   }
      end
      # Assert.assert_equal (1 == 2), true, 'findlive_sub : It was not good though it was repeated 262144 times!'
      [-1, @live]
    end
  end
end
