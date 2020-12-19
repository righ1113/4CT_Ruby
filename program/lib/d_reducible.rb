# frozen_string_literal: true

require '../lib/c_const'
require '../lib/c_read_file'
require 'active_support'
require 'active_support/core_ext'

# Reducible モジュール
module Reducible
  # Reducible クラス
  class Reducible
    include Const
    include ReadFile
    include GetAdjmat

    # attr_accessor :r_axles

    def initialize
      # 好配置を読み込む
      @g_confs = GoodConfs.new

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

    def update_reducible(deg, axles)
      @r_axles[:low][0] = axles[:low][axles[:lev]].deep_dup
      @r_axles[:upp][0] = axles[:upp][axles[:lev]].deep_dup

      puts 'Testing reducibility. Putting input axle on stack.'

      noconf    = 633 # 好配置の個数
      num_axles = 1
      while num_axles.positive?
        num_axles -= 1

        # puts 'Axle from stack:'
        get_adjmat deg, axles, num_axles, @adjmat
        get_edgelist num_axles, deg
        h = 0
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
          v = i # image[i]
          next if @r_axles[:low][num_axles][v] == @r_axles[:upp][num_axles][v]
          # puts 'Lowering upper bound of vertex'
          # p 'fuga' # ("{0} to {1} and adding to stack\n", v, aStack.axle.upp[num_axles][v] - 1);

          Assert.assert_equal (num_axles < Const::MAXASTACK), true, 'More than %d elements in axle stack needed'

          # コピー
          unless num_axles.zero?
            @r_axles[:low][num_axles] = @r_axles[:low][num_axles - 1].deep_dup
            @r_axles[:upp][num_axles] = @r_axles[:upp][num_axles - 1].deep_dup
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

    def get_edgelist(num_axles, deg); end
  end
end
