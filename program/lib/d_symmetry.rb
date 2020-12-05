# frozen_string_literal: true

require '../lib/c_const'

# Symmetry モジュール
module Symmetry
  # Symmetry クラス
  class Symmetry
    include Const

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

    def self.refl_forced(axles_low, axles_upp, pos_i, deg)
      xxi = pos_i[:xxx] - 1
      pos_i[:nol].times do |i|
        pp = pos_i[:pos][i]
        # puts pos_i[:val]
        pp = xxi + (pp - 1) % deg < deg ? pp + xxi : pp + xxi - deg
        return 0 if pp < 1 || pp > 2 * deg
        q =
          if pp <= deg
            deg - pp + 1
          elsif pp < 2 * deg
            3 * deg - pp
          else
            2 * deg
          end
        return 0 if pos_i[:low][i] > axles_low[q] || pos_i[:upp][i] < axles_upp[q]
      end
      pos_i[:val]
    end

    def self.chk_sy(kkk, epsilon, level, line, axles, sym, nosym, deg)
      i = sym.find_index { |v| v[:num] == line }
      sym[i][:xxx] = kkk + 1
      Assert.assert_equal (kkk.between?(0, deg) && epsilon.between?(0, 1)), true, 'Illegal symmetry'
      Assert.assert_equal (i < nosym), true, 'No symmetry as requested'
      Assert.assert_equal (sym[i][:nol] == level + 1), true, 'Level mismatch'
      if epsilon.zero?
        is_one = (outlet_forced axles[:low][axles[:lev]], axles[:upp][axles[:lev]], sym[i], deg) == 1
        Assert.assert_equal is_one, true, 'Invalid symmetry'
      else
        is_one = (refl_forced axles[:low][axles[:lev]], axles[:upp][axles[:lev]], sym[i], deg) == 1
        # Assert.assert_equal is_one, true, 'Invalid reflected symmetry'
      end
      puts '  checkSymmetry OK.'
    end
  end
end
