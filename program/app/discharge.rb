# frozen_string_literal: true

# $ cd program/app
# $ ruby discharge.rb 7
# irb なら
# $ irb
# > load 'discharge.rb'
# > Discharge.discharge 7

require '../lib/c_const'
require '../lib/c_read_file'
require '../lib/d_lib_reduce'
require '../lib/d_condition'

# LibReduce 他をインクルードするため、クラスにする
class Discharge
  include Const
  include ReadFile
  include LibReduce
  include Condition

  def self.discharge(degree = 7)
    # deg と axles
    @deg = degree
    puts "中心の次数 deg: #{@deg}"

    # @axles の初期化
    @axles = {
      low: Array.new(Const::MAXLEV + 1, Array.new(Const::CARTVERT, 0)),
      upp: Array.new(Const::MAXLEV + 1, Array.new(Const::CARTVERT, 0)),
      lev: 0
    }
    @axles[:low][0][0] = @deg
    (5 * @deg).times { |n| @axles[:low][0][n + 1] = 5 }
    @axles[:upp][0][0] = @deg
    (5 * @deg).times { |n| @axles[:upp][0][n + 1] = Const::INFTY }

    # LibReduce クラスのインスタンスを作る
    reduce = LibReduce.new
    reduce.r_axles[:low][0][3] = 7
    p reduce.r_axles[:low][0]

    # Rules クラスのインスタンスを作る
    rules = Rules.new
    p rules.dummy

    # Tactics クラスのインスタンスを作る
    tactics = Tactics.new
    p tactics.dummy
    p tactics.tacs[0]
    p tactics.tacs[1]
    p tactics.tacs[2]
    p tactics.tacs[13]

    # Condition クラスのインスタンスを作る
    condition = Condition.new

    Assert.assertions = 0
    Assert.assert_equal (2 + 1), 3, 'fail1'

    ret = main_loop reduce, condition, rules, tactics
    # final check
    if ret == 'Q.E.D.'
      puts "中心の次数 #{@deg} のグラフは、電荷が負になるか、近くに好配置があらわれるかです。"
    else
      puts '実装中です。'
    end
  end

  def self.main_loop(reduce, condition, _rules, tactics)
    p @axles[:lev]
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
        puts 'Reduce.'
        p reduce.update_reduce @deg, @axles
        @axles[:lev] -= 1
      when 'H'
        puts 'Hubcap.'
        @axles[:lev] -= 1
      when 'C'
        puts 'Condition.'
        condition.update_condition1 tac[2].to_i, tac[3].to_i, @axles
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
