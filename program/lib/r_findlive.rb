# frozen_string_literal: true

require '../lib/c_const'

# Findlive モジュール
module Findlive
  # FindliveR クラス
  class FindliveR
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
      @n_live, @live = findlive_sub(bigno, angle, ring, ed, ncodes, j, c, forbidden) do |ccc, jjj, edd, extent|
        ccc[jjj] <<= 1
        ret1, *a  = while (ccc[jjj] & 8) != 0
                      if jjj >= edd - 1
                        print_status ring, ncodes, extent, exm
                        break [true, jjj, ccc]
                      end
                      jjj += 1
                      ccc[jjj] <<= 1
                    end
        if ret1
          jjj, ccc = a
          [true, jjj, ccc]
        else
          [false, jjj, ccc]
        end
      end
    end

    def findlive_sub(bigno, angle, ring, edd, ncodes, jjj, ccc, forbidden)
      Assert.assert_equal (1 == 2), true, 'no block!' unless block_given?
      extent = 0
      262_144.times do |_cnt|
        while (forbidden[jjj] & ccc[jjj]) != 0
          ret1, jjj, ccc = yield ccc, jjj, edd, extent
          return [ncodes - extent, @live] if ret1
        end

        if jjj == ring + 1
          extent = record ccc, ring, angle, extent, bigno
          ret1, jjj, ccc = yield ccc, jjj, edd, extent
          return [ncodes - extent, @live] if ret1
        else
          jjj -= 1
          return [ncodes - extent, @live] if jjj.negative?
          ccc[jjj], u = 1, 0
          (1..angle[jjj][0]).each { |i| u |= ccc[angle[jjj][i]] }
          forbidden[jjj] = u
        end
      end
      Assert.assert_equal (1 == 2), true, 'findlive_sub : It was not good though it was repeated 262144 times!'
      [-1, @live] # ここには来ない
    end

    def record(col, ring, angle, extent, bigno)
      # Given a colouring specified by a 1,2,4-valued function "col", it computes
      # the corresponding number, checks if it is in live, and if so removes it.
      weight = [0, 0, 0, 0, 0]
      (1..ring).each do |i|
        sum = 7 - col[angle[i][1]] - col[angle[i][2]]
        # sum = sum >= 5 ? 4 : sum
        # sum = sum <= -1 ? 0 : sum
        weight[sum] += Const::POWER[i]
      end

      min = max = weight[4]
      (1..2).each do |i|
        w = weight[i]
        if w < min
          min = w
        elsif w > max
          max = w
        end
      end

      colno = bigno - 2 * min - max
      (extent += 1; @live[colno] = 0) if @live[colno] != 0
      extent
    end

    def print_status(ring, totalcols, extent, extentclaim)
      print "\n\n   This has ring-size #{ring}, so there are #{totalcols} colourings total,\n"
      print "   and #{Const::SIMATCHNUMBER[ring]} balanced signed matchings.\n"
      print "\n   There are #{extent} colourings that extend to the configuration."
      print " #{extent} #{extentclaim}"
      Assert.assert_equal (extent == extentclaim), true, '***ERROR: DISCREPANCY IN NUMBER OF EXTENDING COLOURINGS***'
      print "\n\n            remaining               remaining balanced\n"
      print "           colourings               signed matchings\n"
      printf "\n             %04d", (totalcols - extent)
    end
  end
end
