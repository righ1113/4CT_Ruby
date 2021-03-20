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
      # for (v = 1; v <= graph[0+1][0]; v++) {
      #   for (h = 1; h <= graph[v+2][0+1]; h++) {
      #     if ((v <= graph[0+1][1]) && (h == graph[v+2][0+1]))
      #       continue;
      #     if (h >= graph[v+2].Length)
      #       break;
      #     i = (h < graph[v+2][1]) ? h + 1 : 1;
      #     u = graph[v+2][h+1];
      #     w = graph[v+2][i+1];
      #     a = edgeno[v][w];
      #     b = edgeno[u][w];
      #     c = edgeno[u][v];
      #     // どっちかが0なら通過
      #     Debug.Assert((contract[a]==0 || contract[b]==0),
      #       "         ***  ERROR: CONTRACT IS NOT SPARSE  ***\n\n");
      #     if (a > c) {
      #       d = (angle[c][0] >= 4) ? 4 : ++angle[c][0];
      #       angle[c][d] = a;
      #       if ((contract[a] == 0) && (contract[b] == 0) && (contract[c] == 0)) {
      #         e = (diffangle[c][0] >= 4) ? 4 : ++diffangle[c][0];
      #         diffangle[c][e] = a;
      #       }
      #       if (contract[b] != 0) {
      #         e = (sameangle[c][0] >= 4) ? 4 : ++sameangle[c][0];
      #         sameangle[c][e] = a;
      #       }
      #     }
      #     if (b > c) {
      #       d = (angle[c][0] >= 4) ? 4 : ++angle[c][0];
      #       angle[c][d] = b;
      #       if ((contract[a] == 0) && (contract[b] == 0) && (contract[c] == 0)) {
      #         e = (diffangle[c][0] >= 4) ? 4 : ++diffangle[c][0];
      #         diffangle[c][e] = b;
      #       }
      #       if (contract[a] != 0) {
      #         e = (sameangle[c][0] >= 4) ? 4 : ++sameangle[c][0];
      #         sameangle[c][e] = b;
      #       }
      #     }
      #   }
      # }
    end

    def angles_sub3(_g_conf)
      _neighbour = Array.new(Const::MVERTS, false)
      # /* checking that there is a triad */
      # if (contract[0] < 4)
      #   return;
      # for (v = graph[0+1][1] + 1; v <= graph[0+1][0]; v++) {
      #   /* v is a candidate triad */
      #   for (a = 0, i = 1; i <= graph[v+2][0+1]; i++) {
      #     u = graph[v+2][i+1];
      #     for (j = 1; j <= 8; j++)
      #       if (u == graph[2][j]) {
      #           a++;
      #           break;
      #       }
      #   }
      #   if (a < 3)
      #     continue;
      #   if (graph[v+2][0] >= 6)
      #     return;
      #   for (u = 1; u <= graph[0+1][0]; u++)
      #     neighbour[u] = false;
      #   for (i = 1; i <= graph[v+2][0+1]; i++)
      #     neighbour[graph[v+2][i]] = true;
      #   for (j = 1; j <= 8; j++) {
      #     if (!neighbour[graph[2][j]])
      #       return;
      #   }
      # }
      # Debug.Assert(false,
      #   "         ***  ERROR: CONTRACT HAS NO TRIAD  ***\n\n");
    end
  end
end
