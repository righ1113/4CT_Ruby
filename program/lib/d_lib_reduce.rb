# frozen_string_literal: true

require '../lib/c_read_file'

# LibReduce モジュール
module LibReduce
  # LibReduce クラス
  class LibReduce
    include ReadFile

    MAXVAL     = 12
    CARTVERT   = 5 * MAXVAL + 2 # domain of l_A, u_A, where A is an axle
    MAXELIST   = 134            # length of edgelist[a][b]
    MAXSTACK   = 5              # max height of Astack (see "Reduce")
    MAXLEV     = 12             # max level of an input line + 1

    attr_accessor :r_axles

    def initialize
      # 好配置を読み込む
      GoodConfs.new

      # インスタンス変数を作る
      @r_axles = {
        low: Array.new(MAXLEV + 1, Array.new(CARTVERT, 0)),
        upp: Array.new(MAXLEV + 1, Array.new(CARTVERT, 0)),
        lev: 0
      }
      @adjmat   = Array.new(CARTVERT, Array.new(CARTVERT, 0))
      @edgelist = Array.new(12, Array.new(9, Array.new(MAXELIST, 0)))
      @used     = Array.new(CARTVERT, false)
      @image    = Array.new(CARTVERT, 0)
    end

    def update_reduce(deg, axles)
      r_axles[:low][0] = axles[:low][axles[:lev]]
      r_axles[:upp][0] = axles[:upp][axles[:lev]]

      puts 'Testing reducibility. Putting input axle on stack.'

      noconf    = 633 # 好配置の個数
      num_axles = 1
      while num_axles.positive? && num_axles < MAXASTACK
        num_axles -= 1
        puts 'Axle from stack:'
        get_adjmat   num_axles deg
        get_edgelist num_axles deg
        # for (h = 0; h < noconf; ++h)
        #   if SubConf(aStack.adjmat, aStack.axle.upp[num_axles], rP2.redquestions[h], edgelist, image, used)
        #     break
        if h == noconf
          puts 'Not reducible'
          return false
        end
        # Semi-reducibility test found h-th configuration, say K, appearing
        redverts = 5 # rP2.redquestions[h].qa[1];
        redring  = 1 # rP2.redquestions[h].qb[1];
        # the above are no vertices and ring-size of free completion of K
        # could not use conf[h][0][0], because conf may be NULL

        # p ("Conf({0},{1},{2}): ", h / 70 + 1, (h % 70) / 7 + 1, h % 7 + 1)
        (1..redverts).each do |j|
          if image[j] != -1
            p 'hoge' # (" {0}({1})", rP2.image.ver[j], j);
          end
        end

        # omitted
        # if (conf != NULL)
        #   CheckIso(conf[h], B, image, lineno);
        # Double-check isomorphism

        ((redring + 1)..redverts).each do |i|
          v = image[i]
          r_axles[:low][num_axles][v] == r_axles[:upp][num_axles][v] && next
          puts 'Lowering upper bound of vertex'
          p 'fuga' # ("{0} to {1} and adding to stack\n", v, aStack.axle.upp[num_axles][v] - 1);

          # Debug.Assert((num_axles < MAXASTACK),
          #   "More than %d elements in axle stack needed\n");

          r_axles[:upp][num_axles][v] -= 1
          num_axles += 1
        end
      end

      puts 'All possibilities for lower degrees tested'
      true
    end

    def get_adjmat(num_axles, deg); end

    def get_edgelist(num_axles, deg); end
  end
end
