# frozen_string_literal: true

# $ cd program/app
# $ ruby discharge.rb 7
# irb なら
# $ irb
# > load 'discharge.rb'
# > Discharge.discharge 7

require '../lib/c_read_file'
require '../lib/d_lib_reduce'

# LibReduce をインクルードするため、クラスにする
class Discharge
  include ReadFile
  include LibReduce

  def self.discharge(deg = 7)
    puts "中心の次数 deg : #{deg}"

    # LibReduce クラスのインスタンスを作る
    reduce = LibReduce.new
    reduce.r_axles[:low][0][3] = 7
    p reduce.r_axles[:low][0]

    # Tactics クラスのインスタンスを作る
    tactics = Tactics.new
    p tactics.dummy
  end
end

if __FILE__ == $PROGRAM_NAME
  if %w[7 8 9 10 11].find_index(ARGV[0]).nil?
    Discharge.discharge
  else
    Discharge.discharge ARGV[0].to_i
  end
end
