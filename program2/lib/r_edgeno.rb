# frozen_string_literal: true

require '../lib/c_const'

# EdgeNo モジュール
module EdgeNo
  # EdgeNo クラス
  class EdgeNo
    include Const

    attr_reader :edgeno

    def initialize(g_conf)
      verts, ring = g_conf[0 + 1][0], g_conf[0 + 1][1] # ring-size
      @edgeno     = Array.new(Const::EDGES) { Array.new(Const::EDGES, 0) }

      # 1. stripSub1
      (1..ring).each do |v|
        u = v > 1 ? v - 1 : ring
        @edgeno[u][v] = @edgeno[v][u] = v
      end
      done, term = Array.new(Const::MVERTS, false), 3 * (verts - 1) - ring

      # 2. stripSub2
      # This eventually lists all the internal edges of the configuration
      term = strip_sub2 g_conf, verts, ring, done, term

      # 3. stripSub3
      # Now we must list the edges between the interior and the ring
      strip_sub3 g_conf, ring, done, term
    end

    private

    def strip_sub2(g_conf, verts, ring, done, term)
      best, max = 1, Array.new(Const::MVERTS, 0)

      ((ring + 1)..verts).each do |_cnt|
        # First we find all vertices from the interior that meet the "done"
        # vertices in an interval, and write them in max[1] .. max[maxes]
        maxint = maxes = 0
        ((ring + 1)..verts).each do |v|
          next if done[v]
          inter = in_interval g_conf[v + 2], done
          if inter > maxint
            maxint, maxes, max[1] = inter, 1, v
          elsif inter == maxint
            maxes += 1
            max[maxes] = v
          end
        end

        # From the terms in max we choose the one of maximum degree
        maxdeg = 0
        (1..maxes).each do |h|
          d = g_conf[max[h] + 2][0 + 1]
          maxdeg, best = d, max[h] if d > maxdeg
        end
        # So now, the vertex "best" will be the next vertex to be done

        d        = g_conf[best + 2][0 + 1]
        first    = 1
        previous = done[g_conf[best + 2][d + 1]] # この3行、多重代入できなかった
        while previous || !done[g_conf[best + 2][first + 1]]
          previous = done[g_conf[best + 2][1 + first]]
          first += 1
          (first = 1; break) if first > d
        end

        h = first
        while done[g_conf[best + 2][h + 1]]
          @edgeno[best][g_conf[best + 2][h + 1]] = @edgeno[g_conf[best + 2][h + 1]][best] = term
          term -= 1
          (break if first == 1; h = 0) if h == d
          h += 1
        end
        done[best] = true
      end
      # This eventually lists all the internal edges of the configuration
      term
    end

    def in_interval(grav, done)
      d = grav[0 + 1]
      first = in_get d, 1, true, done, grav
      return (done[grav[d + 1]] ? 1 : 0) if first == d
      last = in_get d, first, false, done, grav
      length = last - first + 1
      return length if last == d

      (((last + 2)..d).each { |j| return 0 if done[grav[j + 1]] }; return length) if first > 1

      worried = false
      ((last + 2)..d).each do |j|
        if done[grav[j + 1]]
          length, worried = length + 1, true
        elsif worried
          return 0
        end
      end
      length
    end

    def in_get(ddd, xxx, f_flg, done, grav)
      f_flg ? (xxx += 1 while xxx < ddd && !done[grav[xxx + 1]]) : (xxx += 1 while xxx < ddd && done[grav[1 + xxx + 1]])
      xxx
    end

    def strip_sub3(g_conf, ring, done, term)
      ring.times do |_cnt|
        maxint, best, v = 0, 0, 1
        while v <= ring
          unless done[v]
            u, w                   = v > 1 ? v - 1 : ring, v < ring ? v + 1 : 1
            done_int_u, done_int_w = done[u] ? 1 : 0, done[w] ? 1 : 0
            inter                  = 3 * g_conf[v + 2][0 + 1] + 4 * (done_int_u + done_int_w)
            maxint, best           = inter, v if inter > maxint
          end
          v += 1
        end

        grav, u = g_conf[best + 2], best > 1 ? best - 1 : ring
        my_each = done[u] ? (2..(grav[0 + 1] - 1)).reverse_each : (2..(grav[0 + 1] - 1)).each
        my_each.with_index do |h, _|
          @edgeno[best][grav[h + 1]] = @edgeno[grav[h + 1]][best] = term
          term -= 1
        end
        done[best] = true
      end
    end
  end
end
