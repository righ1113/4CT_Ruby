# frozen_string_literal: true

require '../lib/c_const'
require 'active_support'
require 'active_support/core_ext'
require 'json'

# Rules クラスと LibReduce クラスから include される
module GetAdjmat
  include Const

  private

  def get_adjmat(deg, axles, num_axles, adjmat)
    Const::CARTVERT.times do |a|
      Const::CARTVERT.times { |b| adjmat[a][b] = -1 }
    end
    deg.times do |ii|
      i = ii + 1
      h = i == 1 ? deg : i - 1
      chg_adjmat adjmat, 0, h, i, :forward
      a = deg + h
      chg_adjmat adjmat, i, h, a, :forward
      do_fan deg, i, axles[:upp][num_axles][i], adjmat if axles[:upp][num_axles][i] < 9
    end
  end

  def do_fan(deg, iii, kkk, adjmat)
    i, k = iii, kkk
    a = i == 1 ? 2 * deg : deg + i - 1
    b = deg + i
    c = 2 * deg + i
    d = 3 * deg + i
    e = 4 * deg + i
    case k
    when 5
      chg_adjmat adjmat, i, a, b, :backward
    when 6
      chg_adjmat adjmat, i, a, c, :backward
      chg_adjmat adjmat, i, c, b, :backward
    when 7
      chg_adjmat adjmat, i, a, c, :backward
      chg_adjmat adjmat, i, c, d, :backward
      chg_adjmat adjmat, i, d, b, :backward
    else
      chg_adjmat adjmat, i, a, c, :backward
      chg_adjmat adjmat, i, c, d, :backward
      chg_adjmat adjmat, i, d, e, :backward
      chg_adjmat adjmat, i, e, b, :backward
    end
  end

  def chg_adjmat(adjmat, aaa, bbb, ccc, way)
    a, b, c = aaa, bbb, ccc
    adjmat[a][b] = c
    if way == :forward
      adjmat[c][a] = b
      adjmat[b][c] = a
    else
      adjmat[b][c] = a
      adjmat[c][a] = b
    end
  end
end

# ReadFile モジュール
module ReadFile
  # ReadFile スーパークラス
  class ReadFile
    def initialize(_deg = nil, _axles = nil); end

    private

    def read_file; end
  end

  # sub class 1
  class GoodConfs < ReadFile
    def initialize
      super
      read_file
    end

    private

    def read_file
      File.open('../4ct_data/d_good_confs.json') do |file|
        @g_confs = JSON.load file # Hashに変換
      end
      # p @g_confs[10]
      # p @g_confs[10]['a']
    end
  end

  # sub class 2
  class Rules < ReadFile
    include Const
    include GetAdjmat

    U        = [0, 0, 0, 1, 0, 3, 2, 1, 4, 3, 8, 3, 0, 0, 5, 6, 15].freeze
    V        = [0, 0, 1, 0, 2, 0, 1, 3, 2, 5, 2, 9, 4, 12, 0, 1, 1].freeze
    DIFNOUTS = [0, 0, 0, 0, 0, 0, 0, 103, 103, 103, 103, 103].freeze

    def initialize(deg, axles)
      super

      # インスタンス変数を作る
      posout0 = {
        num: 0,
        nol: 0,
        val: 0,
        pos: Array.new(17, 0),
        low: Array.new(17, 0),
        upp: Array.new(17, 0),
        xxx: 0
      }
      @posout = Array.new(2 * Const::MAXOUTLETS) { posout0 }

      @adjmat = Array.new(Const::CARTVERT) { Array.new(Const::CARTVERT, 0) }

      read_file deg, axles
    end

    def update_hubcap(deg, axles, tac_v)
      # 1. omitted
      # 2. omitted
      # 3. omitted
      # 4. omitted
      # 5.
      nouts = DIFNOUTS[deg]
      s = Array.new(2 * Const::MAXOUTLETS + 1, 0)
      tac_v.each do |xs|
        puts "--> Checking hubcap member (#{xs[0]}, #{xs[1]}, #{xs[2]})"
        (nouts - 1).times { |j| @posout[j][:xxx] = xs[0]; s[j] = 0 }
        if xs[0] != xs[1]
          (nouts - 1).times { |j| @posout[nouts + j][:xxx] = xs[1]; s[nouts + j] = 0 }
          s[2 * nouts] = 99 # to indicate end of list
        else
          s[nouts] = 99 # to indicate end of list
        end
        update_bound s, xs[2], 0, 0, deg, axles
      end
    end

    private

    def read_file(deg, axles)
      p 'Rules read_file() start'
      rules = nil
      File.open('../4ct_data/d_rules.json') do |file|
        rules = JSON.load file # Hashに変換
      end
      # p rules[10]['z']

      # set data
      index = 0
      rules.each do |line|
        index += 1 if do_outlet deg, axles,  line['z'][1], line['z'], line['b'], index
        index += 1 if do_outlet deg, axles, -line['z'][1], line['z'], line['b'], index
      end
      # データを2回重ねる
      index.times do |i|
        @posout[i + index][:num] = @posout[i][:num]
        @posout[i + index][:nol] = @posout[i][:nol]
        @posout[i + index][:val] = @posout[i][:val]
        @posout[i + index][:pos] = @posout[i][:pos].deep_dup
        @posout[i + index][:low] = @posout[i][:low].deep_dup
        @posout[i + index][:upp] = @posout[i][:upp].deep_dup
        @posout[i + index][:xxx] = @posout[i][:xxx]
      end
    end

    def do_outlet(deg, axles, number, zzz, bbb, index)
      get_adjmat deg, axles, axles[:lev], @adjmat
      now_pos = @posout[index]
      now_pos[:nol] = zzz[0] - 1
      now_pos[:num] = number
      phi = []
      k   = 0
      17.times { |i| phi[i] = -1 }
      phi[0], phi[1], now_pos[:val], k = number.positive? ? [1, 0, 1, 1] : [0, 1, -1, 0]
      now_pos[:pos][0] = 1
      # compute phi
      i = 0
      zzz[0].times do |j|
        now_pos[:low][i] = bbb[j] / 10
        now_pos[:upp][i] = bbb[j] % 10
        now_pos[:upp][i] = Const::INFTY if now_pos[:upp][i] == 9
        now_pos[:low][i] = now_pos[:upp][i] if now_pos[:low][i].zero?
        if j == k
          return false unless deg.between?(now_pos[:low][k], now_pos[:upp][k])
          # if above true then outlet cannot apply for this degree
          next
        end
        if j >= 2	# now computing T->pos[i]
          u = phi[U[zzz[j]]]
          v = phi[V[zzz[j]]]
          now_pos[:pos][i], phi[zzz[j]] = @adjmat[u][v], @adjmat[u][v]
        end
        u = now_pos[:pos][i]
        # update adjmat
        do_fan deg, u, axles[:upp][axles[:lev]][i], @adjmat if u <= deg && now_pos[:low][i] == now_pos[:upp][i]
        i += 1
      end
      # Condition (T4) is checked in CheckIso
      true
    end

    def update_bound(sss, _maxch, _pos, _depth, _deg, axles)
      # 1. compute forced and permitted rules, allowedch, forcedch, update s
      forcedch = 0; allowedch = 0; i = -1
      posout = nil
      while sss[i] < 99
        i += 1
        forcedch += @posout[i][:val] if sss[i].positive?
        next if sss[i] != 0
        if !(outlet_forced axles[:low][axles[:lev]], axles[:upp][axles[:lev]], posout).zero?
          sss[i] = 1
          forcedch += @posout[i][:val]
        elsif (outlet_permitted axles[:low][axles[:lev]], axles[:upp][axles[:lev]], posout).zero?
          sss[i] = -1
        elsif @posout[i][:val].positive?
          allowedch += @posout[i][:val]
        end
      end
    end

    def outlet_forced(_axles_low, _axles_upp, _posout)
      1
    end

    def outlet_permitted(_axles_low, _axles_upp, _posout)
      1
    end
  end

  # sub class 3
  class Tactics < ReadFile
    attr_reader :tacs

    def initialize
      super
      read_file
    end

    private

    def read_file
      p 'Tactics read_file() start'
      @tacs = []
      File.foreach('../4ct_data/d_tactics07.txt') do |line|
        tacs << line.chomp.split
      end
    end
  end
end
