# frozen_string_literal: true

# Symmetry モジュール
module Symmetry
  # Symmetry クラス
  class Symmetry
    def self.del_sym(nosym, nolines, lev)
      return nosym if nosym < 1 || nolines[nosym - 1][:nol] - 1 < lev
      del_sym (nosym - 1), nolines, lev
    end

    def self.outlet_forced(axles_low, axles_upp, pos_i, deg)
      xxi = pos_i[:xxx] - 1
      pos_i[:nol].times do |i|
        p = pos_i[:pos][i]
        p = xxi + (p - 1) % deg < deg ? p + xxi : p + xxi - deg
        return 0 if pos_i[:low][i] > axles_low[p] || pos_i[:upp][i] < axles_upp[p]
      end
      pos_i[:val]
    end

    def self.outlet_permitted(axles_low, axles_upp, pos_i, deg)
      xxi = pos_i[:xxx] - 1
      pos_i[:nol].times do |i|
        p = pos_i[:pos][i]
        p = xxi + (p - 1) % deg < deg ? p + xxi : p + xxi - deg
        return 0 if pos_i[:low][i] > axles_upp[p] || pos_i[:upp][i] < axles_low[p]
      end
      pos_i[:val]
    end
  end
end
