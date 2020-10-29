# frozen_string_literal: true

require '../lib/c_read_file'

# LibReduce モジュール
module LibReduce
  # LibReduce クラス
  class LibReduce
    include ReadFile

    def initialize
      GoodConfs.new
    end
  end
end
