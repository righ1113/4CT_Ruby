# frozen_string_literal: true

require '../lib/c_const'
require 'active_support'
require 'active_support/core_ext'
require 'json'

# Rules クラスと LibReduce クラスから include される
module GetAdjmat
  private

  def get_adjmat(num_axles, deg); end
end

# ReadFile モジュール
module ReadFile
  # ReadFile スーパークラス
  class ReadFile
    def initialize(_axles = nil); end

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

    attr_reader :rules

    def initialize(axles)
      super
      # インスタンス変数を作る
      @num = Array.new(Const::MAXSYM + 1, 0)
      @nol = Array.new(Const::MAXSYM + 1, 0)
      @val = Array.new(Const::MAXSYM + 1, 0)
      @pos = Array.new(Const::MAXSYM + 1, Array.new(17, 0))
      @low = Array.new(Const::MAXSYM + 1, Array.new(17, 0))
      @upp = Array.new(Const::MAXSYM + 1, Array.new(17, 0))
      @xxx = Array.new(Const::MAXSYM + 1, 0)

      @adjmat = Array.new(Const::CARTVERT, Array.new(Const::CARTVERT, 0))

      read_file axles
    end

    private

    def do_outlet(axles, number, zzz, bbb, index)
      # aaaaa
      true
    end

    def read_file(axles)
      p 'Rules read_file() start'
      File.open('../4ct_data/d_rules.json') do |file|
        @rules = JSON.load file # Hashに変換
      end
      # p @rules[10]['z']

      # set data
      index = 0
      @rules.each do |line|
        index += 1 if do_outlet axles,  line['z'][1], line['z'], line['b'], index
        index += 1 if do_outlet axles, -line['z'][1], line['z'], line['b'], index
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
