# frozen_string_literal: true

# Symmetry モジュール
module Symmetry
  # Symmetry クラス
  class Symmetry
    def self.outlet_forced(_axles_low, _axles_upp, _pos_i)
      1
    end

    def self.outlet_permitted(_axles_low, _axles_upp, _pos_i)
      1
    end
  end
end
