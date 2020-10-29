# frozen_string_literal: true

# ReadFile モジュール
module ReadFile
  # ReadFile スーパークラス
  class ReadFile
    def read_file; end
  end

  # sub class 1
  class GoodConfs < ReadFile
    def initialize
      super
      read_file
    end

    def read_file
      p self
    end
  end

  # sub class 3
  class Tactics < ReadFile
    attr_reader :dummy

    def initialize
      super
      read_file
      @dummy = 3
    end

    def read_file
      p 'Tactics read_file() start & goal'
    end
  end
end
