# frozen_string_literal: true

require '../lib/c_const'

# Angles モジュール
module Angles
  # AnglesR クラス
  class AnglesR
    include Const

    attr_reader :angle, :diffangle, :sameangle, :contract

    def initialize(g_conf, edgeno)
      # @type const Const::EDGES: Integer
      # @type const Assert: untyped
      edge = 3 * g_conf[0 + 1][0] - 3 - g_conf[0 + 1][1]

      @angle     = Array.new(Const::EDGES) { Array.new(5, 0) }
      @diffangle = Array.new(Const::EDGES) { Array.new(5, 0) }
      @sameangle = Array.new(Const::EDGES) { Array.new(5, 0) }

      @contract               = Array.new((Const::EDGES + 1), 0)
      @contract[0]            = g_conf[1 + 1][0] # number of edges in contract
      @contract[Const::EDGES] = g_conf[0 + 1][3]
      (1..@contract[0]).each do |i|
        u, v = g_conf[2][2 * i - 1], g_conf[2][2 * i]
        Assert.assert_equal (edgeno[u][v] >= 1), true, '***  ERROR: CONTRACT CONTAINS NON-EDGE  ***'
        @contract[edgeno[u][v]] = 1
      end

      (Const::EDGES - 1).times { |i| @angle[i][0] = @diffangle[i][0] = @sameangle[i][0] = 0 }
      @diffangle[0][0] = @angle[0][0] = g_conf[0 + 1][0]
      @diffangle[0][1] = @angle[0][1] = g_conf[0 + 1][1]
      @diffangle[0][2] = @angle[0][2] = edge

      # findanglesSub2
      angles_sub2 g_conf, edgeno

      # findanglesSub3
      angles_sub3 g_conf
    end

    private

    def angles_sub2(g_conf, edgeno)
      # @type const Assert: untyped
      (1..g_conf[0 + 1][0]).each do |v|
        (1..g_conf[v + 2][0 + 1]).each do |h|
          next if v <= g_conf[0 + 1][1] && h == g_conf[v + 2][0 + 1]
          break (0..1) if h >= g_conf[v + 2].length
          i       = h < g_conf[v + 2][1] ? h + 1 : 1
          u, w    = g_conf[v + 2][h + 1], g_conf[v + 2][i + 1]
          a, b, c = edgeno[v][w], edgeno[u][w], edgeno[u][v]
          # どっちかが0なら通過
          str = '***  ERROR: CONTRACT IS NOT SPARSE  ***'
          Assert.assert_equal (@contract[a].zero? || @contract[b].zero?), true, str
          angles_sub2_sub a, b, c
          angles_sub2_sub b, a, c
        end
      end
      true
    end

    def angles_sub2_sub(xxx, yyy, ccc)
      x, y, c = xxx, yyy, ccc
      return unless x > c
      d            = @angle[c][0] >= 4 ? 4 : @angle[c][0] += 1
      @angle[c][d] = x
      if @contract[x].zero? && @contract[y].zero? && @contract[c].zero?
        e                = @diffangle[c][0] >= 4 ? 4 : @diffangle[c][0] += 1
        @diffangle[c][e] = x
      end
      return if @contract[y].zero?
      e                = @sameangle[c][0] >= 4 ? 4 : @sameangle[c][0] += 1
      @sameangle[c][e] = x
    end

    def angles_sub3(g_conf)
      # @type const Const::MVERTS: Integer
      # @type const Assert: untyped
      neighbour = Array.new(Const::MVERTS, false)
      # checking that there is a triad
      return true if @contract[0] < 4
      v = g_conf[0 + 1][1] + 1
      while v <= g_conf[0 + 1][0]
        # v is a candidate triad
        a, i = 0, 1
        while i <= g_conf[v + 2][0 + 1]
          u = g_conf[v + 2][i + 1]
          (1..8).each { |j| (a += 1; next) if u == g_conf[2][j] }
          i += 1
        end

        next if a < 3
        return true if g_conf[v + 2][0] >= 6
        (1..g_conf[0 + 1][0]).each     { |x| neighbour[x.to_i] = false }
        (1..g_conf[v + 2][0 + 1]).each { |y| neighbour[g_conf[y + 2][i]] = true }
        (1..8).each                    { |j| return true unless neighbour[g_conf[2][j]] }
        v += 1
      end
      Assert.assert_equal (1 == 2), true, '***  ERROR: CONTRACT HAS NO TRIAD  ***'
      false # ここには来ない
    end
  end
end
