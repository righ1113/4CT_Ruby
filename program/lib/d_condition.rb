# frozen_string_literal: true

require '../lib/c_const'
require 'active_support'
require 'active_support/core_ext'

# Conditon モジュール
module Condition
  # Condition クラス
  class Condition
    include Const

    def update_condition1(n_ind, m_ind, axles)
      axles[:low][axles[:lev] + 1] = axles[:low][axles[:lev]].deep_dup
      axles[:upp][axles[:lev] + 1] = axles[:upp][axles[:lev]].deep_dup

      a_low_n = axles[:low][axles[:lev]][n_ind]
      a_upp_n = axles[:upp][axles[:lev]][n_ind]

      if m_ind.positive?
        # new lower bound
        # Assert.assert_equal (a_low_n >= m_ind || m_ind > a_upp_n), false, 'Invalid lower bound in condition'
        axles[:upp][axles[:lev]    ][n_ind] = m_ind - 1
        axles[:low][axles[:lev] + 1][n_ind] = m_ind
      else
        # new upper bound
        # Assert.assert_equal (a_low_n > -m_ind || -m_ind >= a_upp_n), false, 'Invalid upper bound in condition'
        axles[:low][axles[:lev]    ][n_ind] = 1 - m_ind
        axles[:upp][axles[:lev] + 1][n_ind] = -m_ind
      end
    end

    def update_condition2
      #      # remember symmetry unless contains a fan vertex
      #      good = true
      #      for i in 0..axles.lev do
      #        if (nn.[i] > 2 * deg || nn.[i] < 1) then
      #        # if (1 <= nn.[i] && nn.[i] <= 2 * deg) then
      #          good = false
      #      if good then # remember symmetry
      #        Debug.Assert((nosym < MAXSYM), "Too many symmetries")
      #        # T = &sym[nosym + 1];
      #        sym.number.[nosym] <- lineno
      #        sym.value.[nosym] <- 1
      #        sym.nolines.[nosym] <- axles.lev + 1
      #        for i in 0..axles.lev do
      #          sym.pos.[nosym].[i] <- nn.[i]
      #          if (mm.[i] > 0) then
      #            sym.plow.[nosym].[i] <- mm.[i]
      #            sym.pupp.[nosym].[i] <- INFTY
      #          else
      #            sym.plow.[nosym].[i] <- 5
      #            sym.pupp.[nosym].[i] <- -mm.[i]
      #
      #      nn.[axles.lev]     <- n
      #      nn.[axles.lev + 1] <- 0
      #      mm.[axles.lev]     <- m
      #      mm.[axles.lev + 1] <- 0
      #
      #      if good then
      #        ((nn, mm), (axles.low, axles.upp, axles.lev), nosym + 1)
      #      else
      #        ((nn, mm), (axles.low, axles.upp, axles.lev), nosym)
      #      end
    end
  end
end
