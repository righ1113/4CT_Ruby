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
      file = File.new('../4ct_data/d_good_confs.json')
      @data = JSON.load file # Hashに変換
      file.close
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
      File.open(format('../4ct_data/d_tactics%02<num>d.txt', num: deg)) do |f|
        f.each_line do |line|
          tacs << line.chomp.split # chomp: 改行文字を削除
        end
      end
      true
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
      # rbs に File.open()が定義されていない
      file = File.new('../4ct_data/r_good_confs.json')
      @data = JSON.load file # 3D配列 に変換
      file.close
      true
    end
  end
end
