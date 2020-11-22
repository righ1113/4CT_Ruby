# frozen_string_literal: true

# $ cd program/app
# $ ruby discharge.rb 7
# irb なら
# $ irb
# > load 'discharge.rb'
# > Discharge.discharge 7

require '../lib/c_const'
require '../lib/c_read_file'
require '../lib/d_rules'
require '../lib/d_reducible'
require '../lib/d_condition'

# LibReduce 他をインクルードするため、クラスにする
class Discharge
  include Const
  include ReadFile
  include Rules
  include Reducible
  include Condition

  def self.discharge(degree = 7)
    # @deg
    @deg = degree
    puts "中心の次数 deg: #{@deg}"

    # @axles の初期化
    @axles = {
      low: Array.new(Const::MAXLEV + 1) { Array.new(Const::CARTVERT, 0) },
      upp: Array.new(Const::MAXLEV + 1) { Array.new(Const::CARTVERT, 0) },
      lev: 0
    }
    @axles[:low][0][0] = @deg
    (5 * @deg).times { |n| @axles[:low][0][n + 1] = 5 }
    @axles[:upp][0][0] = @deg
    (5 * @deg).times { |n| @axles[:upp][0][n + 1] = Const::INFTY }

    # Reducible クラスのインスタンスを作る
    reducible = Reducible.new
    # reduce.r_axles[:low][0][3] = 7
    # p reduce.r_axles[:low][0]

    # Rules クラスのインスタンスを作る
    rules = Rules.new @deg, @axles

    # Tactics クラスのインスタンスを作る
    tactics = Tactics.new

    # Condition クラスのインスタンスを作る
    condition = Condition.new

    Assert.assertions = 0
    Assert.assert_equal (2 + 1), 3, 'fail1'

    ret = main_loop reducible, condition, rules, tactics
    # final check
    if ret == 'Q.E.D.'
      puts "中心の次数 #{@deg} のグラフは、電荷が負になるか、近くに好配置があらわれるかです。"
    else
      puts '実装中です。'
    end
  end

  def self.main_loop(reducible, condition, rules, tactics)
    tactics.tacs.each_with_index do |tac, i|
      # 下に空行を入れるらしい
      break 'Q.E.D.' if tac[0] == 'Q.E.D.' && @axles[:lev] == -1

      puts "#{i}: #{tac}"
      case tac[1]
      when '7', '8', '9', '10', '11'
        puts '0th line.'
      when 'S'
        puts 'Symmetry.'
        @axles[:lev] -= 1
      when 'R'
        puts 'Reducible.'
        p reducible.update_reducible @deg, @axles
        @axles[:lev] -= 1
      when 'H'
        puts 'Hubcap.'
        # p (tac[2..-1].map { |e1| e1.delete('(').delete(')').split(',').map(&:to_i) })
        rules.update_hubcap @deg, @axles, (tac[2..-1].map { |e1| e1.delete('(').delete(')').split(',').map(&:to_i) })
        @axles[:lev] -= 1
      when 'C'
        puts 'Condition.'
        condition.update_condition1 tac[2].to_i, tac[3].to_i, @axles
        condition.update_condition2 tac[2].to_i, tac[3].to_i, @axles, @deg, i + 1
        @axles[:lev] += 1
      else
        Assert.assert_equal (1 == 2), true, "無効なtactic: #{tac}"
      end
      break 'ahaha' if tac[1] == 'S' # 暫定脱出
    end
  end
end

# メイン関数としたもの
if __FILE__ == $PROGRAM_NAME
  if %w[7 8 9 10 11].include?(ARGV[0])
    Discharge.discharge ARGV[0].to_i
  else
    Discharge.discharge
  end
end
