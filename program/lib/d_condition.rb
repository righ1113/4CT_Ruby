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
      @sym_num = Array.new(Const::MAXSYM + 1, 0)
      @sym_nol = Array.new(Const::MAXSYM + 1, 0)
      @sym_val = Array.new(Const::MAXSYM + 1, 0)
      @sym_pos = Array.new(Const::MAXSYM + 1, Array.new(17, 0))
      @sym_low = Array.new(Const::MAXSYM + 1, Array.new(17, 0))
      @sym_upp = Array.new(Const::MAXSYM + 1, Array.new(17, 0))
      @sym_xxx = Array.new(Const::MAXSYM + 1, 0)

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
        Assert.assert_equal (a_low_n >= m_ind || m_ind > a_upp_n), false, 'Invalid lower bound in condition'
        axles[:upp][axles[:lev]    ][n_ind] = m_ind - 1
        axles[:low][axles[:lev] + 1][n_ind] = m_ind
      else
        # new upper bound
        Assert.assert_equal (a_low_n > -m_ind || -m_ind >= a_upp_n), false, 'Invalid upper bound in condition'
        axles[:low][axles[:lev]    ][n_ind] = 1 - m_ind
        axles[:upp][axles[:lev] + 1][n_ind] = -m_ind
      end
    end

    def update_condition2(n_ind, m_ind, axles, deg, lineno)
      # remember symmetry unless contains a fan vertex
      good = true
      (axles[:lev]).times { |i| good = false if @nnn[i] > 2 * deg || @nnn[i] < 1 }
      if good # remember symmetry
        Assert.assert_equal (@nosym < Const::MAXSYM), true, 'Too many symmetries'
        @sym_num[@nosym] = lineno
        @sym_val[@nosym] = 1
        @sym_nol[@nosym] = axles[:lev] + 1
        (axles[:lev]).times do |i|
          @sym_pos[@nosym][i] = @nnn[i]
          if @mmm[i].positive?
            @sym_low[@nosym][i] = @mmm[i]
            @sym_upp[@nosym][i] = Const::INFTY
          else
            @sym_low[@nosym][i] = 5
            @sym_upp[@nosym][i] = @mmm[i]
          end
        end
      end
      @nnn[axles[:lev]]     = n_ind
      @nnn[axles[:lev] + 1] = 0
      @mmm[axles[:lev]]     = m_ind
      @mmm[axles[:lev] + 1] = 0
      @nosym += 1 if good
    end
  end
end
