# frozen_string_literal: true

require '../lib/c_const'

# Strip モジュール
module Strip
  # Strip クラス
  class Strip
    include Const

    attr_reader :edgeno

    def initialize(g_conf)
      verts   = g_conf[0 + 1][0]
      ring    = g_conf[0 + 1][1] # ring-size
      @edgeno = Array.new(Const::EDGES) { Array.new(Const::EDGES, 0) }

      # 1. stripSub1
      ring.times do |vv|
        v = vv + 1
        u = v > 1 ? v - 1 : ring
        @edgeno[u][v] = v
        @edgeno[v][u] = v
      end
      _done0 = Array.new(Const::MVERTS, false)
      _term  = 3 * (verts - 1) - ring

      # 2. stripSub2
      # This eventually lists all the internal edges of the configuration
      # 3. stripSub3
      # Now we must list the edges between the interior and the ring
    end
  end
end
