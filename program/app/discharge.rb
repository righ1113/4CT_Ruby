# frozen_string_literal: true

# $ cd program/app
# $ ruby discharge.rb 7
# irb なら
# $ irb
# > load 'discharge.rb'
# > discharge

require '../lib/d_lib_reduce'

# comment
class Discharge
  include Reduce

  def self.discharge(deg = 7)
    p deg
    Reduce.new
  end
end

if __FILE__ == $PROGRAM_NAME
  if %w[7 8 9 10 11].find_index(ARGV[0]).nil?
    Discharge.discharge
  else
    Discharge.discharge ARGV[0].to_i
  end
end
