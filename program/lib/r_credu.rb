# frozen_string_literal: true

require '../lib/c_const'

# CRedu モジュール
module CRedu
  # CReduR クラス
  class CReduR
    include Const

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
      start -= 1 until contract[start].zero?
      c[start], j = 1, start - 1
      j -= 1 until contract[j].zero?
      dm, sm = diffangle[j], sameangle[j]
      c[j], u = 1, 4
      imax1 = dm[0] >= 4 ? 4 : dm[0]
      (1..imax1).each { |i| u |= c[dm[i]] }
      imax2 = sm[0] >= 4 ? 4 : sm[0]
      (1..imax2).each { |i| u |= ~c[sm[i]] }
      forbidden[j] = u

      check_c_reduce forbidden, c, contract, j, start, diffangle, sameangle, bigno, ring, live

      # p 'CReduR.'
    end

    private

    def check_c_reduce(forbidden, ccc, contract, jjj, start, diffangle, sameangle, bigno, ring, live)
      # @type const Assert: untyped
      c, j = ccc, jjj
      2_097_152.times do
        until (forbidden[j] & c[j]).zero?
          c[j] <<= 1
          until (c[j] & 8).zero?
            loop { j += 1; break if contract[j].zero? }
            if j >= start
              puts '               ***  Contract confirmed 1 ***'
              return true
            end
            c[j] <<= 1
          end
        end
        if j == 1
          Assert.assert_equal in_live(c, ring, live, bigno), true, 'ERROR: INPUT CONTRACT IS INCORRECT  ***\n\n'
          c[j] <<= 1
          until (c[j] & 8).zero?
            loop { j += 1; break if contract[j].zero? }
            if j >= start
              puts '               ***  Contract confirmed 2 ***'
              return true
            end
            c[j] <<= 1
          end
          next
        end
        return false if j <= 0
        loop { j -= 1; break if contract[j].zero? }
        dm, sm = diffangle[j], sameangle[j]
        c[j], u = 1, 0
        (1..4).each do |i|
          u |=  c[dm[i]] if i <= dm[0]
          u |= ~c[sm[i]] if i <= sm[0]
        end
        forbidden[j] = u
      end
      Assert.assert_equal (1 == 2), true, 'check_c_reduce : It was not good though it was repeated 2097152 times!'
      false # ここには来ない
    end

    def in_live(col, ring, live, bigno)
      # Same as "record" above, except now it returns whether the colouring is in
      # live, and does not change live. */
      # @type const Const::POWER: Array[Integer]
      weight = Array.new(5, 0)
      (1..4).each { |i| weight[i] = 0 }
      (1..ring).each { |i| weight[col[i]] += Const::POWER[i] }
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
      return true if live[colno].zero?
      false
    end
  end
end
