# frozen_string_literal: true

require '../lib/c_const'

# CRedu モジュール
module CRedu
  # CRedu クラス
  class CRedu
    include Const

    def initialize(g_conf, n_live, live, diffangle, sameangle, contract)
      ring    = g_conf[0 + 1][1]                     # ring-size
      _ncodes = (Const::POWER[ring] + 1) / 2         # number of codes of colorings of R
      bigno   = (Const::POWER[ring + 1] - 1) / 2     # needed in "inlive"

      Const.assert (contract[0] != 0),                 true, '       ***  ERROR: NO CONTRACT PROPOSED  ***\n\n'
      Const.assert (n_live == contract[Const::EDGES]), true, ' ***  ERROR: DISCREPANCY IN EXTERIOR SIZE  ***\n\n'

      start     = diffangle[0][2]
      c         = Array.new(Const::EDGES, 0)
      forbidden = Array.new(Const::EDGES, 0) # called F in the notes
      start -= 1 until contract[start].zero?
      c[start], j = 1, start - 1
      j -= 1 until contract[j].zero?
      dm, sm = diffangle[j], sameangle[j]
      c[j], u = 1, 4
      (1..dm[0]).each { |i| u |= c[dm[i]] }
      (1..sm[0]).each { |i| u |= ~c[sm[i]] }
      forbidden[j] = u

      check_c_reduce(forbidden, c, contract, j, start, diffangle, sameangle, bigno, ring, live) do |c2, j2, start2, contract2|
        ret, *a = until (c2[j2] & 8).zero?
                    loop { j2 += 1; break if contract2[j2].zero? }
                    if j2 >= start2
                      puts '               ***  Contract confirmed ***'
                      break [true, j2, c2]
                    end
                    c2[j2] <<= 1
                  end
        if ret
          j2, c2 = a
          [true,  j2, c2]
        else
          [false, j2, c2]
        end
      end

      # p 'CReduR.'
    end

    private

    def check_c_reduce(forbidden, c, contract, j, start, diffangle, sameangle, bigno, ring, live)
      2_097_152.times do
        until (forbidden[j] & c[j]).zero?
          c[j] <<= 1
          ret, j, c = yield c, j, start, contract # ブロックを実行する
          return true if ret
        end
        if j == 1
          Const.assert in_live(c, ring, live, bigno), true, 'ERROR: INPUT CONTRACT IS INCORRECT  ***\n\n'
          c[j] <<= 1
          ret, j, c = yield c, j, start, contract
          return true if ret
          next
        end
        return false if j <= 0
        loop { j -= 1; break if contract[j].zero? }
        dm, sm = diffangle[j], sameangle[j]
        c[j], u = 1, 0
        (1..4).each do |i|
          u |= c[dm[i]] if i <= dm[0]
          u |= ~c[sm[i]] if i <= sm[0]
        end
        forbidden[j] = u
      end
      Const.assert (1 == 2), true, 'check_c_reduce : It was not good though it was repeated 2097152 times!'
      false # ここには来ない
    end

    def in_live(col, ring, live, bigno)
      # Same as "record" above, except now it returns whether the colouring is in
      # live, and does not change live. */
      # @type const Const::POWER: Array[Integer]
      weight = Array.new(5, 0)
      (1..4).each    { |i| weight[i] = 0 }
      (1..ring).each { |i| weight[col[i]] += Const::POWER[i] }

      # ★★★ Egison pattern 2 ★★★
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
      return true if live[colno].zero?
      false
    end
  end
end
