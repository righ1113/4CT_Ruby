# frozen_string_literal: true

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
    def initialize; end

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
    include GetAdjmat

    attr_reader :rules

    def initialize
      super
      read_file
    end

    private

    def read_file
      p 'Rules read_file() start'
      File.open('../4ct_data/d_rules.json') do |file|
        @rules = JSON.load file # Hashに変換
      end
      # p @rules[10]['z']
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
