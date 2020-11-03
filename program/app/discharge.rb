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

# LibReduce 他をインクルードするため、クラスにする
class Discharge
  include Const
  include ReadFile
  include LibReduce

  def self.discharge(degree = 7)
    # deg と axles
    @deg = degree
    puts "中心の次数 deg: #{@deg}"
    @axles = {
      low: Array.new(Const::MAXLEV + 1, Array.new(Const::CARTVERT, 0)),
      upp: Array.new(Const::MAXLEV + 1, Array.new(Const::CARTVERT, 0)),
      lev: 0
    }

    # LibReduce クラスのインスタンスを作る
    i_reduce = LibReduce.new
    i_reduce.r_axles[:low][0][3] = 7
    p i_reduce.r_axles[:low][0]

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

    ret = main_loop i_reduce, rules, tactics
    # final check
    if ret == 'Q.E.D.'
      puts "中心の次数 #{@deg} のグラフは、電荷が負になるか、近くに好配置があらわれるかです。"
    else
      puts '実装中です。'
    end
  end

  def self.main_loop(i_reduce, _rules, tactics)
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
        p i_reduce.update_reduce @deg, @axles
        @axles[:lev] -= 1
      when 'H'
        puts 'Hubcap.'
        @axles[:lev] -= 1
      when 'C'
        puts 'Condition.'
        @axles[:lev] += 1
      else
        raise "無効なtactic: #{tac}"
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
