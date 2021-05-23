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

      ed           = angle[0][2]
      c            = Array.new(Const::EDGES, 0)
      j            = ed - 1
      c[ed]        = 1
      c[j]         = 2
      forbidden    = Array.new(Const::EDGES, 0)
      forbidden[j] = 5
      findlive_sub bigno, angle, ring, ed, extentclaim, ncodes, j, c, forbidden
      #   // 構造体タプルのパターンマッチ
      # match structureTuple with
      #   | struct (ncodes1, live1) -> (@n_live, @live)

      @n_live = 7
    end

    def findlive_sub(bigno, angle, ring, edd, extentclaim, ncodes, jjj, ccc, forbidden)
      # int x, extent=0, u, i;
      # for (x = 0; x < 262144; x++) {
      #   while ((forbidden[j] & c[j]) != 0) {
      #     c[j] <<= 1;
      #     while ((c[j] & 8) != 0) {
      #       if (j >= ed - 1) {
      #           Printstatus(ring, ncodes, extent, extentclaim);
      #           return ((ncodes - extent), live);
      #       }
      #       c[++j] <<= 1;
      #     }
      #   }
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
      # }
      # Debug.Assert(false,
      #   "FindliveSub : It was not good though it was repeated 262144 times!");
      # return (-1, live);
    end
  end
end
