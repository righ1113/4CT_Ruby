# frozen_string_literal: true

require '../lib/c_const'
require '../lib/c_read_file'

# Reducible モジュール
module Reducible
  # ReducibleBase クラス
  class ReducibleBase
    include Const
    include ReadFile
    include GetAdjmat

    def initialize
      # 好配置を読み込む
      @g_confs = GoodConfs.new
      # p @g_confs.data[10]['a']

      # インスタンス変数を作る
      @r_axles = {
        low: Array.new(Const::MAXLEV + 1) { Array.new(Const::CARTVERT, 0) },
        upp: Array.new(Const::MAXLEV + 1) { Array.new(Const::CARTVERT, 0) },
        lev: 0
      }
      @adjmat   = Array.new(Const::CARTVERT) { Array.new(Const::CARTVERT, 0) }
      @edgelist = Array.new(12) { Array.new(9) { Array.new(Const::MAXELIST, 0) } }
      @used     = Array.new(Const::CARTVERT, false)
      @image    = Array.new(Const::CARTVERT, 0)
    end

    def update_reducible?(deg, axles)
      @r_axles[:low][0] = Const.deep_copy axles[:low][axles[:lev]]
      @r_axles[:upp][0] = Const.deep_copy axles[:upp][axles[:lev]]

      puts 'Testing reducibility. Putting input axle on stack.'

      noconf    = 633 # 好配置の個数
      num_axles = 1
      while num_axles.positive?
        num_axles -= 1

        # puts 'Axle from stack:'
        get_adjmat deg, @r_axles, num_axles, @adjmat
        init_edgelist num_axles, deg
        h =
          noconf.times do |hh|
            break hh if sub_conf? hh, deg, @r_axles[:upp][num_axles]
          end
        if h == noconf
          puts 'Not reducible'
          return false
        end

        # Semi-reducibility test found h-th configuration, say K, appearing
        # the above are no vertices and ring-size of free completion of K
        # could not use conf[h][0][0], because conf may be NULL
        redverts = @g_confs.data[h]['a'][1]
        redring  = @g_confs.data[h]['b'][1]

        # omitted
        # p ("Conf({0},{1},{2}): ", h / 70 + 1, (h % 70) / 7 + 1, h % 7 + 1)
        # (1..redverts).each do |j|
        #   if image[j] != -1
        #     p 'hoge' # (" {0}({1})", rP2.image.ver[j], j);
        #   end
        # end

        # omitted
        # if (conf != NULL)
        #   CheckIso(conf[h], B, image, lineno);
        # Double-check isomorphism

        ((redring + 1)..redverts).each do |i|
          v = @image[i]
          next if @r_axles[:low][num_axles][v] == @r_axles[:upp][num_axles][v]
          # puts 'Lowering upper bound of vertex'
          # p 'fuga' # ("{0} to {1} and adding to stack\n", v, aStack.axle.upp[num_axles][v] - 1);

          Const.assert (num_axles < Const::MAXASTACK), true, 'More than %d elements in axle stack needed'

          # コピー
          unless num_axles.zero?
            @r_axles[:low][num_axles] = Const.deep_copy @r_axles[:low][num_axles - 1]
            @r_axles[:upp][num_axles] = Const.deep_copy @r_axles[:upp][num_axles - 1]
          end
          # デクリメント
          @r_axles[:upp][num_axles][v] -= 1
          # インクリメント
          num_axles += 1
        end
      end

      puts 'All possibilities for lower degrees tested'
      true
    end

    private

    def init_edgelist(num_axles, deg); end

    def sub_conf?(_hhh, _deg, _degree)
      true
    end
  end

  # ReducibleBase を継承する
  class Reducible < ReducibleBase
    private

    def init_edgelist(num_axles, deg)
      (5..11).each do |a|
        (5..8).each do |b|
          break if b > a
          @edgelist[a][b][0] = 0
        end
      end
      upp = @r_axles[:upp][num_axles]
      deg.times do |ii|
        i = ii + 1
        add_to_list 0, i, upp
        h = i == 1 ? deg : i - 1
        add_to_list i, h, upp
        a, b = deg + h, deg + i
        add_to_list i, a, upp
        add_to_list i, b, upp
        (@r_axles[:low][num_axles][i] != upp[i]) && next
        # in this case we are not interested in the fan edges
        (upp[i] == 5) && (add_to_list a, b, upp; next)
        c = 2 * deg + i
        add_to_list a, c, upp
        add_to_list i, c, upp
        (upp[i] == 6) && (add_to_list b, c, upp; next)
        d = 3 * deg + i
        add_to_list c, d, upp
        add_to_list i, d, upp
        (upp[i] == 7) && (add_to_list b, d, upp; next)
        Const.assert (upp[i] == 8), true, 'Unexpected error in `GetEdgeList'
        e = 4 * deg + i
        add_to_list d, e, upp
        add_to_list i, e, upp
        add_to_list b, e, upp
      end
    end

    def add_to_list(u, v, degree)
      # adds the pair u,v to edgelist
      a, b = degree[u], degree[v]
      if (a >= b) && (b <= 8) && (a <= 11) && ((a <= 8) || u.zero?)
        Const.assert (@edgelist[a][b][0] + 2 < Const::MAXELIST), true, 'More than %d entries in edgelist needed'
        @edgelist[a][b][0] += 1
        @edgelist[a][b][@edgelist[a][b][0]] = u
        @edgelist[a][b][0] += 1
        @edgelist[a][b][@edgelist[a][b][0]] = v
      end
      return unless (b >= a) && (a <= 8) && (b <= 11) && ((b <= 8) || v.zero?)
      Const.assert (@edgelist[b][a][0] + 2 < Const::MAXELIST), true, 'More than %d entries in edgelist needed'
      @edgelist[b][a][0] += 1
      @edgelist[b][a][@edgelist[b][a][0]] = v
      @edgelist[b][a][0] += 1
      @edgelist[b][a][@edgelist[b][a][0]] = u
    end

    def sub_conf?(h, deg, degree)
      edg = @edgelist[@g_confs.data[h]['d'][0]][@g_confs.data[h]['d'][1]]
      i = 1
      while i <= edg[0]
        x = edg[i]
        i += 1
        y = edg[i]
        return true if
          rooted_sub_conf?(deg, degree, @g_confs.data[h], x, y, 1) ||
          rooted_sub_conf?(deg, degree, @g_confs.data[h], x, y, 0)
        i += 1
      end
      false
    end

    def rooted_sub_conf?(deg, degree, g_conf, x, y, clock_wise)
      Const::CARTVERT.times do |j|
        @used[j]  = false
        @image[j] = -1
      end
      @image[0] = clock_wise
      @image[g_conf['c'][0]] = x
      @image[g_conf['c'][1]] = y
      @used[x] = true
      @used[y] = true
      j = 2
      while g_conf['a'][j] >= 0
        w =
          if clock_wise != 0
            @adjmat[@image[g_conf['a'][j]]][@image[g_conf['b'][j]]]
          else
            @adjmat[@image[g_conf['b'][j]]][@image[g_conf['a'][j]]]
          end
        return false if w == -1
        return false if (g_conf['d'][j] != 0) && g_conf['d'][j] != degree[w]
        return false if @used[w]
        @image[g_conf['c'][j]] = w
        @used[w] = true
        j += 1
      end

      # test if image is well-positioned
      deg.times do |jj|
        j = jj + 1
        return false if !@used[j] && @used[deg + j] && @used[j == 1 ? 2 * deg : deg + j - 1]
      end

      true
    end
  end
end
