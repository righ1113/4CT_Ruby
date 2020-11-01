# frozen_string_literal: true

# $ cd program/app
# $ ruby discharge.rb 7
# irb なら
# $ irb
# > load 'discharge.rb'
# > Discharge.discharge 7

require '../lib/c_read_file'
require '../lib/d_lib_reduce'

# LibReduce 他をインクルードするため、クラスにする
class Discharge
  include ReadFile
  include LibReduce

  def self.discharge(deg = 7)
    puts "中心の次数 deg: #{deg}"

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

    # main loop
    tactics.tacs.each_with_index do |tac, i|
      next if i.zero? # 下に空行を入れるらしい

      break if tac[0] == 'Q.E.D' # 暫定脱出

      puts "#{i}: #{tac}"
      case tac[1]
      when 'S'
        puts 'Symmetry.'
      when 'R'
        puts 'Reduce.'
      when 'H'
        puts 'Hubcap.'
      when 'C'
        puts 'Condition.'
      else
        raise "無効なtactic: #{tac}"
      end
      break if tac[1] == 'S' # 暫定脱出
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if %w[7 8 9 10 11].include?(ARGV[0])
    Discharge.discharge ARGV[0].to_i
  else
    Discharge.discharge
  end
end
