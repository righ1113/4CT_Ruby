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
      extent = 0
      262_144.times do
        while (forbidden[jjj] & ccc[jjj]) != 0
          ccc[jjj] <<= 1
          while (ccc[jjj] & 8) != 0
            if jjj >= edd - 1
              print_status ring, ncodes, extent, extentclaim
              return [ncodes - extent, @live]
            end
            ccc[jjj] <<= 1
          end
        end
        if jjj == ring + 1
          extent = record ccc, ring, angle, extent, bigno;
          ccc[jjj] <<= 1
          while (ccc[jjj] & 8) != 0
            if jjj >= edd - 1
              print_status ring, ncodes, extent, extentclaim
              return [ncodes - extent, @live]
            end
            jjj += 1
            ccc[jjj] <<= 1
          end
        else
          jjj -= 1
          return [ncodes - extent, @live] if jjj.negative?
          ccc[jjj] = 1
          u = 0
          angle[jjj][0].times do |ii|
            i = ii + 1
            break 0 if i >= 5
            u |= ccc[angle[jjj][i]]
          end
          forbidden[jjj] = u
        end
      end
      # Assert.assert_equal (1 == 2), true, 'findlive_sub : It was not good though it was repeated 262144 times!'
      [-1, @live]
    end

    def record(col, ring, angle, extent, bigno)
      # Given a colouring specified by a 1,2,4-valued function "col", it computes
      # the corresponding number, checks if it is in live, and if so removes it.

      weight = [0, 0, 0, 0, 0]
      ring.times do |ii|
        i = ii + 1
        sum = 7 - col[angle[i][1]] - col[angle[i][2]]
        sum = sum >= 5 ? 4 : sum
        sum = sum <= -1 ? 0 : sum
        weight[sum] += Const::POWER[i]
      end
      min = max = weight[4]
      2.times do |ii|
        i = ii + 1
        w = weight[i]
        if w < min
          min = w
        elsif w > max
          max = w
        end
      end
      colno = bigno - 2 * min - max
      if live[colno] != 0
        extent += 1
        live[colno] = 0
      end

      extent
    end

    def print_status(ring, totalcols, extent, _extentclaim)
      print "\n\n   This has ring-size #{ring}, so there are #{totalcols} colourings total,\n"
      print "   and #{Const::SIMATCHNUMBER[ring]} balanced signed matchings.\n"
      print "\n   There are #{extent} colourings that extend to the configuration."
      # Assert.assert_equal (extent == extentclaim), true, '***ERROR: DISCREPANCY IN NUMBER OF EXTENDING COLOURINGS***'
      print "\n\n            remaining               remaining balanced\n"
      print "           colourings               signed matchings\n"
      printf "\n             %04d\n", (totalcols - extent)
    end
  end
end
