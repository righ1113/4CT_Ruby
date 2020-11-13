# frozen_string_literal: true

require 'json'

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
      p @g_confs[10]
      p @g_confs[10]['a']
    end
  end

  # sub class 2
  class Rules < ReadFile
    attr_reader :dummy

    def initialize
      super
      read_file
      @dummy = 5
    end

    private

    def read_file
      p 'Rules read_file() start & goal'
    end
  end

  # sub class 3
  class Tactics < ReadFile
    attr_reader :dummy, :tacs

    def initialize
      super
      read_file
      @dummy = 3
    end

    private

    def read_file
      p 'Tactics read_file() start & goal'
      @tacs = []
      File.foreach('../4ct_data/d_tactics07.txt') do |line|
        tacs << line.chomp.split
      end
    end
  end
end
