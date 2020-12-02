# frozen_string_literal: true

require '../lib/c_const'
require 'active_support'
require 'active_support/core_ext'

# Conditon モジュール
module Condition
  # Condition クラス
  class Condition
    include Const

    def initialize
      # インスタンス変数を作る
      @sym = Array.new(Const::MAXSYM + 1) do
        {
          num: 0,
          nol: 0,
          val: 0,
          pos: Array.new(17, 0),
          low: Array.new(17, 0),
          upp: Array.new(17, 0),
          xxx: 0
        }
      end

      @nnn = Array.new(Const::MAXLEV, 0)
      @mmm = Array.new(Const::MAXLEV, 0)

      @nosym = 0
    end

    def update_condition1(n_ind, m_ind, axles)
      p n_ind, m_ind

      axles[:low][axles[:lev] + 1] = axles[:low][axles[:lev]].deep_dup
      axles[:upp][axles[:lev] + 1] = axles[:upp][axles[:lev]].deep_dup

      a_low_n = axles[:low][axles[:lev]][n_ind]
      a_upp_n = axles[:upp][axles[:lev]][n_ind]

      if m_ind.positive?
        # new lower bound
        Assert.assert_equal m_ind.between?(a_low_n + 1, a_upp_n), true, 'Invalid lower bound in condition'
        axles[:upp][axles[:lev]    ][n_ind] = m_ind - 1
        axles[:low][axles[:lev] + 1][n_ind] = m_ind
      else
        # new upper bound
        Assert.assert_equal (-m_ind).between?(a_low_n, a_upp_n - 1), true, 'Invalid upper bound in condition'
        axles[:low][axles[:lev]    ][n_ind] = 1 - m_ind
        axles[:upp][axles[:lev] + 1][n_ind] = -m_ind
      end
    end

    def update_condition2(n_ind, m_ind, axles, deg, lineno)
      # remember symmetry unless contains a fan vertex
      good = true
      (axles[:lev]).times { |i| good = false unless @nnn[i].between?(1, 2 * deg) }
      if good # remember symmetry
        Assert.assert_equal (@nosym < Const::MAXSYM), true, 'Too many symmetries'
        @sym[@nosym][:num] = lineno
        @sym[@nosym][:val] = 1
        @sym[@nosym][:nol] = axles[:lev] + 1
        (axles[:lev]).times do |i|
          @sym[@nosym][:pos][i] = @nnn[i]
          if @mmm[i].positive?
            @sym[@nosym][:low][i] = @mmm[i]
            @sym[@nosym][:upp][i] = Const::INFTY
          else
            @sym[@nosym][:low][i] = 5
            @sym[@nosym][:upp][i] = @mmm[i]
          end
        end
      end
      @nosym += 1 if good
      @nnn[axles[:lev]]     = n_ind
      @nnn[axles[:lev] + 1] = 0
      @mmm[axles[:lev]]     = m_ind
      @mmm[axles[:lev] + 1] = 0
    end
  end
end
