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
      done = Array.new(Const::MVERTS, false)
      term = 3 * (verts - 1) - ring

      # 2. stripSub2
      # This eventually lists all the internal edges of the configuration
      term = strip_sub2 g_conf, verts, ring, done, term

      # 3. stripSub3
      # Now we must list the edges between the interior and the ring
      strip_sub3 g_conf, ring, done, term
    end

    private

    def strip_sub2(g_conf, verts, ring, done, term)
      best = 1
      max  = Array.new(Const::MVERTS, 0)

      ((ring + 1)..verts).each do
        # First we find all vertices from the interior that meet the "done"
        # vertices in an interval, and write them in max[1] .. max[maxes]
        maxint = 0
        maxes  = 0

        ((ring + 1)..verts).each do |v|
          next if done[v]
          inter = in_interval g_conf[v + 2], done
          if inter > maxint
            maxint = inter
            maxes  = 1
            max[1] = v
          elsif inter == maxint
            maxes += 1
            max[maxes] = v
          end
        end

        # From the terms in max we choose the one of maximum degree
        maxdeg = 0
        (1..maxes).each do |h|
          d = g_conf[max[h] + 2][0 + 1]
          if d > maxdeg
            maxdeg = d
            best   = max[h]
          end
        end
        # So now, the vertex "best" will be the next vertex to be done

        d        = g_conf[best + 2][0 + 1]
        first    = 1
        previous = done[g_conf[best + 2][d + 1]]

        while previous || !done[g_conf[best + 2][first + 1]]
          previous = done[g_conf[best + 2][1 + first]]
          first += 1
          (first = 1; break) if first > d
        end

        h = first
        while done[g_conf[best + 2][h + 1]]
          @edgeno[best][g_conf[best + 2][h + 1]] = term
          @edgeno[g_conf[best + 2][h + 1]][best] = term
          term -= 1
          if h == d
            break if first == 1
            h = 0
          end
          h += 1
        end
        done[best] = true
      end
      # This eventually lists all the internal edges of the configuration

      term
    end

    def in_interval(grav, done)
      d = grav[0 + 1]

      first = 1
      while first < d && !done[grav[first + 1]] do first += 1 end
      return (done[grav[d + 1]] ? 1 : 0) if first == d

      last = first
      while last < d && done[grav[1 + last + 1]] do last += 1 end
      length = last - first + 1
      return length if last == d

      if first > 1
        ((last + 2)..d).each do |j|
          return 0 if done[grav[j + 1]]
        end
        return length
      end
      worried = false
      ((last + 2)..d).each do |j|
        if done[grav[j + 1]]
          length += 1
          worried = true
        elsif worried
          return 0
        end
      end
      length
    end

    def strip_sub3(g_conf, ring, done, term)
      ring.times do
        maxint = 0
        best   = 0
        v      = 1
        while v <= ring
          unless done[v]
            u          = v > 1 ? v - 1 : ring
            w          = v < ring ? v + 1 : 1
            done_int_u = done[u] ? 1 : 0
            done_int_w = done[w] ? 1 : 0
            inter      = 3 * g_conf[v + 2][0 + 1] + 4 * (done_int_u + done_int_w)
            if inter > maxint
              maxint = inter
              best = v
            end
          end
          v += 1
        end

        grav = g_conf[best + 2]
        u = best > 1 ? best - 1 : ring
        if done[u]
          (2..(grav[0 + 1] - 1)).reverse_each do |h|
            @edgeno[best][grav[h + 1]] = term
            @edgeno[grav[h + 1]][best] = term
            term -= 1
          end
        else
          (2..(grav[0 + 1] - 1)).each do |h|
            @edgeno[best][grav[h + 1]] = term
            @edgeno[grav[h + 1]][best] = term
            term -= 1
          end
        end
        done[best] = true
      end
    end
  end
end
