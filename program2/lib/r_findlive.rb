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

      findlive ring, bigno, ncodes, angle, g_conf[0 + 1][2]
    end

    private

    def findlive(ring, bigno, ncodes, angle, exm)
      # computes {\cal C}_0 and stores it in live. That is, computes codes of
      # colorings of the ring that are not restrictions of tri-colorings of the
      # free extension. Returns the number of such codes
      ed             = angle[0][2]
      c, j           = Array.new(Const::EDGES, 0), ed - 1
      c[ed], c[j]    = 1, 2
      forbidden      = Array.new(Const::EDGES, 0)
      forbidden[j]   = 5
      @n_live, @live = findlive_sub(bigno, angle, ring, ed, ncodes, j, c, forbidden) do |c2, j2, ed2, extent|
        c2[j2] <<= 1
        ret1,  *a = while (c2[j2] & 8) != 0
                      if j2 >= ed2 - 1
                        print_status ring, ncodes, extent, exm
                        break [true, j2, c2]
                      end
                      j2 += 1
                      c2[j2] <<= 1
                    end
        if ret1
          j2, c2 = a
          [true,  j2, c2]
        else
          [false, j2, c2]
        end
      end
    end

    def findlive_sub(bigno, angle, ring, edd, ncodes, j, c, forbidden)
      Const.assert (1 == 2), true, 'no block!' unless block_given?
      extent = 0
      262_144.times do |_cnt|
        while (forbidden[j] & c[j]) != 0
          ret1, j, c = yield c, j, edd, extent # ブロックを実行する
          return [ncodes - extent, @live] if ret1
        end

        if j == ring + 1
          extent = record c, ring, angle, extent, bigno
          ret1, j, c = yield c, j, edd, extent
          return [ncodes - extent, @live] if ret1
        else
          j -= 1
          return [ncodes - extent, @live] if j.negative?
          c[j], u = 1, 0
          (1..angle[j][0]).each { |i| u |= c[angle[j][i]] }
          forbidden[j] = u
        end
      end
      Const.assert (1 == 2), true, 'findlive_sub : It was not good though it was repeated 262144 times!'
      [-1, @live] # ここには来ない
    end

    def record(col, ring, angle, extent, bigno)
      # Given a colouring specified by a 1,2,4-valued function "col", it computes
      # the corresponding number, checks if it is in live, and if so removes it.
      weight = [0, 0, 0, 0, 0]
      match_all((1..ring).to_a.map { |i| [col, angle, weight, Const::POWER, i, true] }) do
        with(_[*_, _[_col, _angle, _weight, _power, _i, __('
            sum = 7 - col[angle[i][1]] - col[angle[i][2]]
            weight[sum] += power[i]
          ')], *_]) { i }
      end

      min_max = [weight[4], weight[4]]
      match_all((1..2).to_a.map { |i| [min_max, weight, i, true] }) do
        with(_[*_, _[_min_max, _weight, _i, __('
            w = weight[i]
            if w < min_max[0]
              min_max[0] = w
            elsif w > min_max[1]
              min_max[1] = w
            end
          ')], *_]) { i }
      end

      colno = bigno - 2 * min_max[0] - min_max[1]
      (extent += 1; @live[colno] = 0) if @live[colno] != 0
      extent
    end

    def print_status(ring, totalcols, extent, extentclaim)
      print "\n\n   This has ring-size #{ring}, so there are #{totalcols} colourings total,\n"
      print "   and #{Const::SIMATCHNUMBER[ring]} balanced signed matchings.\n"
      print "\n   There are #{extent} colourings that extend to the configuration."
      print " #{extent} #{extentclaim}"
      Const.assert (extent == extentclaim), true, '***ERROR: DISCREPANCY IN NUMBER OF EXTENDING COLOURINGS***'
      print "\n\n            remaining               remaining balanced\n"
      print "           colourings               signed matchings\n"
      printf "\n             %04d", (totalcols - extent)
    end
  end
end
