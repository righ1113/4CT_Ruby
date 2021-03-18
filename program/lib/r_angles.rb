# frozen_string_literal: true

require '../lib/c_const'

# Angles モジュール
module Angles
  # Angles クラス
  class Angles
    include Const

    attr_reader :angle, :diffangle, :sameangle

    def initialize(g_conf, edgeno)
      _edge = 3 * g_conf[0 + 1][0] - 3 - g_conf[0 + 1][1]

      @angle = Array.new(Const::EDGES) { Array.new(5, 0) }
      @diffangle = Array.new(Const::EDGES) { Array.new(5, 0) }
      @sameangle = Array.new(Const::EDGES) { Array.new(5, 0) }

      contract = Array.new((Const::EDGES + 1), 0)
      contract[0] = g_conf[1 + 1][0] # number of edges in contract
      contract[Const::EDGES] = g_conf[0 + 1][3]
      contract[0].times do |ii|
        i = ii + 1
        u = g_conf[2][2 * i - 1]
        v = g_conf[2][2 * i]
        # Debug.Assert((edgeno.[u].[v] >= 1),
        #   "         ***  ERROR: CONTRACT CONTAINS NON-EDGE  ***\n\n")
        contract[edgeno[u][v]] = 1
      end

      # for i in 0..(EDGES-1) do
      #   angle[i][0] = 0
      #   diffangle[i][0] = 0
      #   sameangle[i][0] = 0
      # diffangle.[0].[0] <- g_conf[0+1].[0]
      # diffangle.[0].[1] <- g_conf[0+1].[1]
      # diffangle.[0].[2] <- edge
      # angle.[0].[0]     <- diffangle.[0].[0]
      # angle.[0].[1]     <- diffangle.[0].[1]
      # angle.[0].[2]     <- diffangle.[0].[2]

      # findanglesSub2
      # LibReduceAngle.FindanglesSub2 (graph, edgeno, contract, angle, diffangle, sameangle)

      # findanglesSub3
      # LibReduceAngle.FindanglesSub3 (MVERTS, graph, contract)

      # (angle, diffangle, sameangle, contract) : TpAngle * TpAngle * TpAngle * int array
    end
  end
end
