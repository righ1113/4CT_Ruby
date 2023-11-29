# frozen_string_literal: true

require '../lib/c_const'

# DRedu クラスが include する
module StillReal
  include Const

  private

  def augment(n, interval, depth, weight, match_w, pnreal, ring, basecol, on, pbit, prt, nchar, real)
    # Finds all matchings such that every match is from one of the given
    # intervals. (The intervals should be disjoint, and ordered with smallest
    # first, and lower end given first.) For each such matching it examines all
    # signings of it, and adjusts the corresponding entries in "real" and
    # "live". *)
    new_i = Array.new(10, 0)
    check_reality depth, weight, pnreal, ring, basecol, on, pbit, prt, nchar, real
    (1..n).each do |r|
      lower = interval[2 * r - 1]
      upper = interval[2 * r]
      ((lower + 1)..upper).each do |i|
        (lower..(i - 1)).each do |j|
          weight[depth + 1][0] = match_w[i][j][0]
          weight[depth + 1][1] = match_w[i][j][1]
          weight[depth + 1][2] = match_w[i][j][2]
          weight[depth + 1][3] = match_w[i][j][3]
          (1..(2 * r - 2)).each { |h| new_i[h] = interval[h] }
          newn, h2 = r - 1, 2 * r - 1
          if j > lower + 1
            newn += 1
            new_i[h2] = lower
            h2 += 1
            new_i[h2] = j - 1
            h2 += 1
          end
          if i > j + 1
            newn += 1
            new_i[h2] = j + 1
            h2 += 1
            new_i[h2] = i - 1
            # h2 += 1
          end
          augment newn, new_i, (depth + 1), weight, match_w, pnreal, ring, basecol, on, pbit, prt, nchar, real
        end
      end
    end
    true
  end

  def check_reality(depth, weight, pnreal, ring, basecol, on, pbit, prealterm, nchar, real)
    # For a given matching M, it runs through all signings, and checks which of
    # them have the property that all associated colourings belong to "live". It
    # writes the answers into bits of "real", starting at the point specified by
    # "bit" and "realterm". "basecol" is for convenience in computing the
    # associated colourings; it is zero for matchings not incident with "ring".
    # "on" is nonzero iff the matching is incident with "ring". */

    choice = Array.new(8, 0)
    nbits = 1 << (depth - 1)
    # k will run through all subsets of M minus the first match */
    nbits.times do |k|
      if pbit[0].zero?
        pbit[0] = 1
        prealterm[0] += 1
        Const.assert (prealterm[0] <= nchar), true, 'More than %ld entries in real are needed'
      end
      (bit_lshift(pbit); next) if (pbit[0] & real[prealterm[0]]).zero?
      col, parity, left = basecol, ring & 1, k
      (1..(depth - 1)).each do |i|
        if (left & 1) != 0	# i.e. if a_i=1, where k=a_1+2a_2+4a_3+... */
          parity ^= 1 # XOR
          choice[i] = weight[i][1]
          col += weight[i][3]
        else
          choice[i] = weight[i][0]
          col += weight[i][2]
        end
        left >>= 1
      end
      if parity != 0
        choice[depth] = weight[depth][1]
        col += weight[depth][3]
      else
        choice[depth] = weight[depth][0]
        col += weight[depth][2]
      end
      if still_real?(col, choice, depth, on)
        pnreal[0] += 1
      else
        real[prealterm[0]] ^= pbit[0]
      end
      bit_lshift(pbit)
    end
  end

  def bit_lshift(pbit)
    case pbit[0]
    when -128
      pbit[0] = 0
    when 0
      pbit[0] = 1
    when 1, 2, 4, 8, 16, 32
      pbit[0] <<= 1
    when 64
      pbit[0] = -128
    else
      Const.assert (1 == 2), true, "exception! #{pbit[0]}"
    end
    true
  end

  def still_real?(col, choice, depth, on)
    # Given a signed matching, this checks if all associated colourings are in
    # "live", and, if so, records that fact on the bits of the corresponding
    # entries of "live". */
    sum       = Array.new(64, 0)
    twisted   = Array.new(64, 0)
    untwisted = Array.new(64, 0)

    n_twisted = n_untwisted = 0
    if col.negative?
      return false if (@live[-col]).zero?
      twisted[n_twisted] = -col
      n_twisted += 1
      sum[0] = col
    else
      return false if (@live[col]).zero?
      untwisted[n_untwisted] = sum[0] = col
      n_untwisted += 1
    end
    twopower = mark = 1
    2.upto(depth) do |i|
      c = choice[i]
      twopower.times do |j|
        b = sum[j] - c
        if b.negative?
          return false if (@live[-b]).zero? # b が負の場合
          twisted[n_twisted] = -b
          n_twisted += 1
          sum[mark] = b
        else
          return false if (@live[b]).zero?
          untwisted[n_untwisted] = sum[mark] = b
          n_untwisted += 1
        end
        mark += 1
      end
      twopower <<= 1
    end

    # Now we know that every coloring that theta-fits M has its code in
    # "live". We mark the corresponding entry of "live" by theta, that is,
    # set its second, third or fourth bit to 1 */
    if on.zero?
      n_twisted.times   { |i| @live[twisted[i]]   |= 2 }
      n_untwisted.times { |i| @live[untwisted[i]] |= 2 }
    else
      n_twisted.times   { |i| @live[twisted[i]]   |= 8 }
      n_untwisted.times { |i| @live[untwisted[i]] |= 4 }
    end
    true
  end
end

# DRedu モジュール
module DRedu
  # DRedu クラス
  class DRedu
    include Const
    include StillReal

    attr_reader :n_live, :live

    def initialize(g_conf, n_live, live)
      ring    = g_conf[0 + 1][1]                 # ring-size
      ncodes  = (Const::POWER[ring] + 1) / 2     # number of codes of colorings of R
      real    = Array.new(Const::SIMATCHNUMBER[Const::MAXRING] / 8 + 2, 255)
      nchar   = Const::SIMATCHNUMBER[ring] / 8 + 1

      # computes {\cal M}_{i+1} from {\cal M}_i, updates the bits of "real"
      @n_live, @live = n_live, live
      update ring, nchar, ncodes, real
      # computes {\cal C}_{i+1} from {\cal C}_i, updates "live"
    end

    private

    def update(ring, nchar, ncodes, real)
      i = 0
      while i.zero? || (update_sub? ncodes)
        test_match ring, nchar, real
        # computes {\cal M}_{i+1} from {\cal M}_i, updates the bits of "real" */
        i += 1
      end
      true
    end

    def update_sub?(ncodes)
      # runs through "live" to see which colourings still have `real' signed
      # matchings sitting on all three pairs of colour classes, and updates "live"
      # accordingly; returns 1 if nlive got smaller and stayed >0, and 0 otherwise *)
      w = 0
      @live[0] = 15 if @live[0] > 1
      ncodes.times { |i| @live[i] == 15 ? (w += 1; @live[i] = 1) : @live[i] = 0 }
      printf '             %4d', w # left

      if w < @n_live && w.positive?
        @n_live = w
        true
      else
        if w.zero?
          print "\n\n\n                  ***  D-reducible  ***\n"
        else
          print "\n\n\n                ***  Not D-reducible  ***\n"
        end
        @n_live = w
        false
      end
    end

    def test_match(ring, nchar, real)
      # This generates all balanced signed matchings, and for each one, tests
      # whether all associated colourings belong to "live". It writes the answers
      # in the bits of the characters of "real". *)
      # @type const Const::POWER: Array[Integer]
      nreal    = [0]
      # "nreal" will be the number of balanced signed matchings such that all
      # associated colourings belong to "live"; ie the total number of nonzero
      # bits in the entries of "real" *)
      bit      = [1] # -128~127
      realterm = [0]
      # First, it generates the matchings not incident with the last ring edge
      match_w  = Array.new(16) { Array.new(16) { Array.new(4, 0) } }
      interval = Array.new(10, 0)
      weight   = Array.new(16) { Array.new(4, 0) }

      (2..ring).each do |a|
        (1..(a - 1)).each do |b|
          match_w[a][b][0] = (Const::POWER[a] + Const::POWER[b]) * 2
          match_w[a][b][1] = (Const::POWER[a] - Const::POWER[b]) * 2
          match_w[a][b][2] = Const::POWER[a] + Const::POWER[b]
          match_w[a][b][3] = Const::POWER[a] - Const::POWER[b]
        end
      end

      (2..(ring - 1)).each do |a|
        (1..(a - 1)).each do |b|
          n = 0
          weight[1][0] = match_w[a][b][0]
          weight[1][1] = match_w[a][b][1]
          weight[1][2] = match_w[a][b][2]
          weight[1][3] = match_w[a][b][3]
          if b >= 3
            n = 1
            interval[1] = 1
            interval[2] = b - 1
          end
          if a >= b + 3
            n += 1
            interval[2 * n - 1] = b + 1
            interval[2 * n]     = a - 1
          end
          augment n, interval, 1, weight, match_w, nreal, ring, 0, 0, bit, realterm, nchar, real
        end
      end

      # now, the matchings using an edge incident with "ring"
      (2..ring).each do |a|
        (1..(a - 1)).each do |b|
          match_w[a][b][0] = Const::POWER[a] + Const::POWER[b]
          match_w[a][b][1] = Const::POWER[a] - Const::POWER[b]
          match_w[a][b][2] = -Const::POWER[a] - Const::POWER[b]
          match_w[a][b][3] = -Const::POWER[a] - 2 * Const::POWER[b]
        end
      end

      (1..(ring - 1)).each do |b|
        n = 0
        weight[1][0] = match_w[ring][b][0]
        weight[1][1] = match_w[ring][b][1]
        weight[1][2] = match_w[ring][b][2]
        weight[1][3] = match_w[ring][b][3]
        if b >= 3
          n = 1
          interval[1] = 1
          interval[2] = b - 1
        end
        if ring >= b + 3
          n += 1
          interval[2 * n - 1] = b + 1
          interval[2 * n]     = ring - 1
        end
        pow = (Const::POWER[ring + 1] - 1) / 2
        augment n, interval, 1, weight, match_w, nreal, ring, pow, 1, bit, realterm, nchar, real
      end
      printf "                       %d\n", nreal[0] # right
    end
  end
end
