# frozen_string_literal: true

require 'json'

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
    attr_reader :data

    def initialize
      super
      read_file
    end

    private

    def read_file
      File.open('../4ct_data/d_good_confs.json') do |file|
        @data = JSON.load file # Hashに変換
      end
      # p @data[10]
      # p @data[10]['a']
    end
  end

  # sub class 3
  class Tactics < ReadFile
    attr_reader :tacs

    def initialize(deg)
      super
      read_file deg
    end

    private

    def read_file(deg)
      p 'Tactics read_file() start'
      @tacs = []
      File.foreach(format('../4ct_data/d_tactics%02<num>d.txt', num: deg)) do |line|
        tacs << line.chomp.split # chomp: 改行文字を削除
      end
    end
  end

  # reduce で使用
  class GoodConfsR < ReadFile
    attr_reader :data

    def initialize
      super
      read_file
    end

    private

    def read_file
      File.open('../4ct_data/r_good_confs.json') do |file|
        @data = JSON.load file # 3D配列 に変換
        # p @data[0][0][1] # => 7322
      end
    end
  end
end
