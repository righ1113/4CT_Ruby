# frozen_string_literal: true

require '../lib/c_const'

# Angles モジュール
module Angles
  # Angles クラス
  class Angles
    include Const

    attr_reader :angle, :diffangle, :sameangle, :contract

    def initialize(g_conf, edgeno)
      edge = 3 * g_conf[0 + 1][0] - 3 - g_conf[0 + 1][1]

      @angle = Array.new(Const::EDGES) { Array.new(5, 0) }
      @diffangle = Array.new(Const::EDGES) { Array.new(5, 0) }
      @sameangle = Array.new(Const::EDGES) { Array.new(5, 0) }

      @contract = Array.new((Const::EDGES + 1), 0)
      @contract[0] = g_conf[1 + 1][0] # number of edges in contract
      @contract[Const::EDGES] = g_conf[0 + 1][3]
      @contract[0].times do |ii|
        i = ii + 1
        u = g_conf[2][2 * i - 1]
        v = g_conf[2][2 * i]
        Assert.assert_equal (edgeno[u][v] >= 1), true, '***  ERROR: CONTRACT CONTAINS NON-EDGE  ***'
        @contract[edgeno[u][v]] = 1
      end

      (Const::EDGES - 1).times do |i|
        @angle[i][0] = 0
        @diffangle[i][0] = 0
        @sameangle[i][0] = 0
      end
      @diffangle[0][0] = g_conf[0 + 1][0]
      @diffangle[0][1] = g_conf[0 + 1][1]
      @diffangle[0][2] = edge
      @angle[0][0] = @diffangle[0][0]
      @angle[0][1] = @diffangle[0][1]
      @angle[0][2] = @diffangle[0][2]

      # findanglesSub2
      angles_sub2 g_conf, edgeno

      # findanglesSub3
      angles_sub3 g_conf
    end

    private

    def angles_sub2(g_conf, edgeno)
      g_conf[0 + 1][0].times do |vv|
        v = vv + 1
        g_conf[v + 2][0 + 1].times do |hh|
          h = hh + 1
          next if v <= g_conf[0 + 1][1] && h == g_conf[v + 2][0 + 1]
          break 0 if h >= g_conf[v + 2].length
          i = h < g_conf[v + 2][1] ? h + 1 : 1
          u = g_conf[v + 2][h + 1]
          w = g_conf[v + 2][i + 1]
          a = edgeno[v][w]
          b = edgeno[u][w]
          c = edgeno[u][v]
          # どっちかが0なら通過
          str = '***  ERROR: CONTRACT IS NOT SPARSE  ***'
          Assert.assert_equal (@contract[a].zero? || @contract[b].zero?), true, str
          angles_sub2_sub a, b, c
          angles_sub2_sub b, a, c
        end
      end
    end

    def angles_sub2_sub(xxx, yyy, ccc)
      x, y, c = xxx, yyy, ccc
      return unless x > c
      d = @angle[c][0] >= 4 ? 4 : @angle[c][0] += 1
      @angle[c][d] = x
      if @contract[x].zero? && @contract[y].zero? && @contract[c].zero?
        e = @diffangle[c][0] >= 4 ? 4 : @diffangle[c][0] += 1
        @diffangle[c][e] = x
      end
      return if @contract[y].zero?
      e = @sameangle[c][0] >= 4 ? 4 : @sameangle[c][0] += 1
      @sameangle[c][e] = x
    end

    def angles_sub3(g_conf)
      neighbour = Array.new(Const::MVERTS, false)
      # checking that there is a triad
      return if @contract[0] < 4
      v = g_conf[0 + 1][1] + 1
      while v <= g_conf[0 + 1][0]
        # v is a candidate triad
        a, i = 0, 1
        while i <= g_conf[v + 2][0 + 1]
          u = g_conf[v + 2][i + 1]
          8.times do |jj|
            j = jj + 1
            if u == g_conf[2][j]
              a += 1
              next
            end
          end
          i += 1
        end

        next if a < 3
        return if g_conf[v + 2][0] >= 6
        g_conf[0 + 1][0].times do |uu|
          u = uu + 1
          neighbour[u] = false
        end
        g_conf[v + 2][0 + 1].times do |ii|
          i = ii + 1
          neighbour[g_conf[v + 2][i]] = true
        end
        8.times do |jj|
          j = jj + 1
          return unless neighbour[g_conf[2][j]]
        end
        v += 1
      end
      Assert.assert_equal (1 == 2), true, '***  ERROR: CONTRACT HAS NO TRIAD  ***'
    end
  end
end
