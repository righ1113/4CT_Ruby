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
        tacs << line.chomp.split # chomp: 改行文字を削除
      end
    end
  end
end
