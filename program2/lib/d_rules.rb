# frozen_string_literal: true

require '../lib/c_const'
require '../lib/c_read_file'
require '../lib/d_chkapply'
require 'json'

# Rules クラスと Reducible クラスから include される
module GetAdjmat
  include Const

  private

  def get_adjmat(deg, axles, num_axles, adjmat)
    Const::CARTVERT.times do |a|
      Const::CARTVERT.times { |b| adjmat[a][b] = -1 }
    end
    deg.times do |ii|
      i = ii + 1
      h = i == 1 ? deg : i - 1
      chg_adjmat adjmat, 0, h, i, :forward
      a = deg + h
      chg_adjmat adjmat, i, h, a, :forward
      do_fan deg, i, axles[:upp][num_axles][i], adjmat if axles[:upp][num_axles][i] < 9
    end
  end

  def do_fan(deg, i, k, adjmat)
    a = i == 1 ? 2 * deg : deg + i - 1
    b = deg + i
    c = 2 * deg + i
    d = 3 * deg + i
    e = 4 * deg + i
    case k
    when 5
      chg_adjmat adjmat, i, a, b, :backward
    when 6
      chg_adjmat adjmat, i, a, c, :backward
      chg_adjmat adjmat, i, c, b, :backward
    when 7
      chg_adjmat adjmat, i, a, c, :backward
      chg_adjmat adjmat, i, c, d, :backward
      chg_adjmat adjmat, i, d, b, :backward
    else
      chg_adjmat adjmat, i, a, c, :backward
      chg_adjmat adjmat, i, c, d, :backward
      chg_adjmat adjmat, i, d, e, :backward
      chg_adjmat adjmat, i, e, b, :backward
    end
  end

  def chg_adjmat(adjmat, a, b, c, way)
    adjmat[a][b] = c
    if way == :forward
      adjmat[c][a] = b
      adjmat[b][c] = a
    else
      adjmat[b][c] = a
      adjmat[c][a] = b
    end
  end
end

# Rules モジュール
module Rules
  include ReadFile
  # sub class 2
  class Rules < ReadFile
    include Const
    include GetAdjmat

    U        = [0, 0, 0, 1, 0, 3, 2, 1, 4, 3, 8, 3, 0, 0, 5, 6, 15].freeze
    V        = [0, 0, 1, 0, 2, 0, 1, 3, 2, 5, 2, 9, 4, 12, 0, 1, 1].freeze
    DIFNOUTS = [0, 0, 0, 0, 0, 0, 0, 103, 64, 53, 53, 53].freeze

    def initialize(deg, axles)
      super

      # インスタンス変数を作る
      @posout = Array.new(2 * Const::MAXOUTLETS) do
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

      @adjmat = Array.new(Const::CARTVERT) { Array.new(Const::CARTVERT, 0) }

      read_file deg, axles
    end

    private

    def read_file(deg, axles)
      p 'Rules read_file() start'
      rules = nil
      File.open('../4ct_data/d_rules.json') do |file|
        rules = JSON.load file # Hashに変換
      end
      # p rules[10]['z']

      # set data
      index = 0
      rules.each do |line|
        if line['c'] == 'invert'
          index += 1 if do_outlet deg, axles,  line['z'][1], line['z'], line['b'], index, V, U
          index += 1 if do_outlet deg, axles, -line['z'][1], line['z'], line['b'], index, V, U
        else
          index += 1 if do_outlet deg, axles,  line['z'][1], line['z'], line['b'], index, U, V
          index += 1 if do_outlet deg, axles, -line['z'][1], line['z'], line['b'], index, U, V
        end
      end
      # データを2回重ねる
      index.times do |i|
        @posout[i + index][:num] = @posout[i][:num]
        @posout[i + index][:nol] = @posout[i][:nol]
        @posout[i + index][:val] = @posout[i][:val]
        @posout[i + index][:pos] = Const.deep_copy @posout[i][:pos]
        @posout[i + index][:low] = Const.deep_copy @posout[i][:low]
        @posout[i + index][:upp] = Const.deep_copy @posout[i][:upp]
        @posout[i + index][:xxx] = @posout[i][:xxx]
      end
    end

    def do_outlet(deg, axles, number, zzz, bbb, index, xxx, yyy)
      get_adjmat deg, axles, axles[:lev], @adjmat
      now_pos = @posout[index]
      now_pos[:nol] = zzz[0] - 1
      now_pos[:num] = number
      phi = []
      k   = 0
      17.times { |i| phi[i] = -1 }
      phi[0], phi[1], now_pos[:val], k = number.positive? ? [1, 0, 1, 1] : [0, 1, -1, 0]
      now_pos[:pos][0] = 1
      # compute phi
      i = 0
      zzz[0].times do |j|
        now_pos[:low][i] = bbb[j] / 10
        now_pos[:upp][i] = bbb[j] % 10
        now_pos[:upp][i] = Const::INFTY if now_pos[:upp][i] == 9
        now_pos[:low][i] = now_pos[:upp][i] if now_pos[:low][i].zero?
        if j == k
          return false unless deg.between?(now_pos[:low][k], now_pos[:upp][k])
          # if above true then outlet cannot apply for this degree
          next
        end
        if j >= 2	# now computing T->pos[i]
          u = phi[xxx[zzz[j]]]
          v = phi[yyy[zzz[j]]]
          now_pos[:pos][i], phi[zzz[j]] = @adjmat[u][v], @adjmat[u][v]
        end
        u = now_pos[:pos][i]
        # update adjmat
        do_fan deg, u, now_pos[:low][i], @adjmat if u <= deg && now_pos[:low][i] == now_pos[:upp][i]
        i += 1
      end
      # Condition (T4) is checked in CheckIso
      true
    end
  end

  # Rules をさらに継承する
  # 委譲も考えたけど、継承でいいような気がしてきた
  class Hubcap < Rules
    # include Const もいらない
    # def initialize(deg, axles) もいらない
    include Apply

    def update_hubcap(deg, axles, tac_v, reducible)
      # 1. omitted
      # 2. omitted
      # 3. omitted
      # 4. omitted
      # 5.
      nouts = DIFNOUTS[deg]
      s = Array.new(2 * Const::MAXOUTLETS + 1, 0)
      tac_v.each do |xs|
        puts "--> Checking hubcap member (#{xs[0]}, #{xs[1]}, #{xs[2]})"
        nouts.times { |j| @posout[j][:xxx] = xs[0]; s[j] = 0 }
        if xs[0] != xs[1]
          nouts.times { |j| @posout[nouts + j][:xxx] = xs[1]; s[nouts + j] = 0 }
          s[2 * nouts] = 99 # to indicate end of list
        else
          s[nouts] = 99 # to indicate end of list
        end
        update_bound s, xs[2], 0, 0, deg, axles, reducible
      end
    end

    private

    def update_bound(sss, maxch, pos, depth, deg, axles, reducible)
      # 1. compute forced and permitted rules, allowedch, forcedch, update s
      forcedch = 0; allowedch = 0; i = 0
      while sss[i] < 99
        case sss[i]
        when 1
          forcedch += @posout[i][:val]
        when -1
          # Do something if sss[i] is -1
        else
          if !(Apply.outlet_forced      axles[:low][axles[:lev]], axles[:upp][axles[:lev]], @posout[i], deg).zero?
            sss[i] = 1
            forcedch += @posout[i][:val]
          elsif (Apply.outlet_permitted axles[:low][axles[:lev]], axles[:upp][axles[:lev]], @posout[i], deg).zero?
            sss[i] = -1
          elsif @posout[i][:val].positive?
            allowedch += @posout[i][:val]
          end
        end
        i += 1
      end
      # 2.
      print "#{depth} POs: "
      i = 0
      while sss[i] < 99
        (i += 1; next) if sss[i].negative?
        print '?' if sss[i].zero?
        print "#{@posout[i][:num]},#{@posout[i][:xxx]} "
        i += 1
      end
      puts ''
      # 3. check if inequality holds
      if forcedch + allowedch <= maxch
        puts "#{depth} Inequality holds. Case done."
        return true
      end
      # 4. check reducibility
      if forcedch > maxch
        Const.assert (reducible.update_reducible? deg, axles), true, 'Incorrect hubcap upper bound'
        puts "#{forcedch} #{allowedch} #{maxch} Reducible. Case done."
        return true
      end
      # 5.
      return true if update_bound_sub5 sss, maxch, pos, depth, deg, axles, forcedch, allowedch, reducible
      # 6.
      Const.assert (1 == 2), true, 'Unexpected error 101'
      false
    end

    def update_bound_sub5(sss, maxch, pos, depth, deg, axles, forcedch, allowedch, reducible)
      # 5.
      while sss[pos] < 99
        (pos += 1; next) if sss[pos] != 0 || @posout[pos][:val].negative?
        x = @posout[pos][:xxx]

        # accepting positioned outlet PO, computing AA
        axles2 = Const.deep_copy axles
        @posout[pos][:nol].times do |k|
          p = @posout[pos][:pos][k]
          p = x - 1 + (p - 1) % deg < deg ? p + x - 1 : p + x - 1 - deg
          axles2[:low][axles2[:lev]][p] = @posout[pos][:low][k] if @posout[pos][:low][k] > axles2[:low][axles2[:lev]][p]
          axles2[:upp][axles2[:lev]][p] = @posout[pos][:upp][k] if @posout[pos][:upp][k] < axles2[:upp][axles2[:lev]][p]
          Const.assert (axles2[:low][axles2[:lev]][p] <= axles2[:upp][axles2[:lev]][p]), true, 'Unexp error 321'
        end

        # Check if a previously rejected positioned outlet is forced to apply
        good = 1
        pos.times do |ii|
          is_zero =
            (Apply.outlet_forced axles2[:low][axles2[:lev]], axles2[:upp][axles2[:lev]], @posout[ii], deg).zero?
          if sss[ii] == -1 && !is_zero
            print "#{depth} Positioned outlet "
            puts "#{@posout[pos][:num]}, #{x} can't be forced, b'z it forces #{@posout[ii][:num]}, #{@posout[ii][:xxx]}"
            good = 0
            break
          end
        end
        unless good.zero?
          # recursion with PO forced
          s_prime = Const.deep_copy sss
          s_prime[pos] = 1
          print "#{depth} Starting recursion with "
          puts "#{@posout[pos][:num]}, #{x} forced"
          update_bound s_prime, maxch, (pos + 1), (depth + 1), deg, axles2, reducible
        end
        # rejecting positioned outlet PO
        puts "#{depth} Rejecting positioned outlet "
        puts "#{@posout[pos][:num]}, #{x}"
        sss[pos] = -1
        allowedch -= @posout[pos][:val]
        if allowedch + forcedch <= maxch
          puts 'Inequality holds.'
          return true
        else
          puts ''
        end
        pos += 1
      end
      false
    end
  end
end
