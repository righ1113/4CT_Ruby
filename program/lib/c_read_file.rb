# frozen_string_literal: true

require '../lib/c_const'
require 'active_support'
require 'active_support/core_ext'
require 'json'

# Rules クラスと LibReduce クラスから include される
module GetAdjmat
  private

  def get_adjmat(deg, axles, num_axles, adjmat); end

  def do_fan(deg, iii, kkk, adjmat); end
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

    U = [0, 0, 0, 1, 0, 3, 2, 1, 4, 3, 8, 3, 0, 0, 5, 6, 15].freeze
    V = [0, 0, 1, 0, 2, 0, 1, 3, 2, 5, 2, 9, 4, 12, 0, 1, 1].freeze

    def initialize(deg, axles)
      super

      # インスタンス変数を作る
      @num = Array.new(Const::MAXSYM + 1, 0)
      @nol = Array.new(Const::MAXSYM + 1, 0)
      @val = Array.new(Const::MAXSYM + 1, 0)
      @pos = Array.new(Const::MAXSYM + 1) { Array.new(17, 0) }
      @low = Array.new(Const::MAXSYM + 1) { Array.new(17, 0) }
      @upp = Array.new(Const::MAXSYM + 1) { Array.new(17, 0) }
      @xxx = Array.new(Const::MAXSYM + 1, 0)

      @adjmat = Array.new(Const::CARTVERT) { Array.new(Const::CARTVERT, 0) }

      read_file deg, axles
    end

    private

    def do_outlet(deg, axles, number, zzz, bbb, index)
      get_adjmat deg, axles, axles[:lev], @adjmat
      @nol[index] = zzz[0] - 1
      @num[index] = number
      phi = []
      k   = 0
      17.times { |i| phi[i] = -1 }
      phi[0], phi[1], @val[index], k = number.positive? ? [1, 0, 1, 1] : [0, 1, -1, 0]
      @pos[index][0] = 1
      # compute phi
      i = 0
      zzz[0].times do |j|
        @low[index][i] = bbb[j] / 10
        @upp[index][i] = bbb[j] % 10
        @upp[index][i] = Const::INFTY   if @upp[index][i] == 9
        @low[index][i] = @upp[index][i] if @low[index][i].zero?
        if j == k
          return false unless deg.between?(@low[index][k], @upp[index][k])
          # if above true then outlet cannot apply for this degree
          next
        end
        if j >= 2	# now computing T->pos[i]
          u = phi[U[zzz[j]]]
          v = phi[V[zzz[j]]]
          @pos[index][i] = @adjmat[u][v]
          phi[zzz[j]]    = @adjmat[u][v]
        end
        u = @pos[index][i]
        # update adjmat
        do_fan deg, u, axles[:upp][axles[:lev]][i], @adjmat if u <= deg && @low[index][i] == @upp[index][i]
        i += 1
      end
      # Condition (T4) is checked in CheckIso
      false
    end

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
        @num[i + index] = @num[i]
        @nol[i + index] = @nol[i]
        @val[i + index] = @val[i]
        @pos[i + index] = @pos[i].deep_dup
        @low[i + index] = @low[i].deep_dup
        @upp[i + index] = @upp[i].deep_dup
        @xxx[i + index] = @xxx[i]
      end
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
