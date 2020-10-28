# frozen_string_literal: true

# comment
module ReadFile
  # comment
  class ReadFile
    def read_file; end
  end

  # comment
  class GoodConfs < ReadFile
    def initialize
      super
      read_file
    end

    def read_file
      p self
    end
  end
end
