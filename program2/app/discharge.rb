# frozen_string_literal: true

# ・以下は1回だけおこなう
# rbenv で Ruby 3.2.2(じゃなくてもいい) を入れる
# $ gem install bundler
# $ cd program2
# $ bundle install --path=vendor/bundle

# ・実行方法
# $ cd program2/app
# $ bundle exec ruby discharge.rb 11                  (3m)

require '../lib/c_const'
require '../lib/c_read_file'
require '../lib/d_rules'
require '../lib/d_reducible'
require '../lib/d_casesplit'
require '../lib/d_chkapply'
require 'egison'

include Egison

# Reducible他 をインクルードするため、クラスにする
class Discharge
  include Const
  include ReadFile
  include Rules
  include Reducible
  include CaseSplit
  include Apply

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

    # CaseSplit クラスのインスタンスを作る
    c_split = CaseSplit.new

    # Hubcap < Rules クラスのインスタンスを作る
    hubcap = Hubcap.new @deg, @axles

    # Reducible クラスのインスタンスを作る
    reducible = Reducible.new

    # Tactics クラスのインスタンスを作る
    tactics = Tactics.new @deg

    Const.assert 1 + 1, 2, 'fail1'

    ret = main_loop c_split, hubcap, reducible, tactics
    # final check
    if ret == 'Q.E.D.'
      puts "Q.E.D. 中心の次数 #{@deg} のグラフは、電荷が負になるか、近くに好配置があらわれるかです。"
    else
      puts '実装中です。'
    end
  end

  def self.main_loop(c_split, hubcap, reducible, tactics)
    tactics.tacs.each_with_index do |tac, i|
      break 'Q.E.D.' if tac[0] == 'Q.E.D.' && @axles[:lev] == -1

      puts "#{i}: #{tac}"
      case tac[1]
      when '7', '8', '9', '10', '11'
        puts '0th line.'
      when 'C'
        puts 'CaseSplit.'
        c_split.update_casesplit1 tac[2].to_i, tac[3].to_i, @axles
        c_split.update_casesplit2 tac[2].to_i, tac[3].to_i, @axles, @deg, i + 1
        @axles[:lev] += 1
      when 'H'
        puts 'Hubcap.'
        hubcap.update_hubcap(
          @deg,
          @axles,
          tac[2..].map { |e1| e1.delete('(').delete(')').split(',').map(&:to_i) },
          reducible
        )
        c_split.down_nosym @axles[:lev]; @axles[:lev] -= 1
      when 'R'
        puts 'Reducible.'
        Const.assert (reducible.update_reducible? @deg, @axles), true, 'Reducibility failed'
        c_split.down_nosym @axles[:lev]; @axles[:lev] -= 1
      when 'S'
        puts 'Apply.'
        Apply.chk tac[2].to_i, tac[3].to_i, tac[4].to_i, tac[5].to_i, @axles, c_split.sym, c_split.nosym, @deg
        c_split.down_nosym @axles[:lev]; @axles[:lev] -= 1
      else
        Const.assert (1 == 2), true, "無効な tactic: #{tac}"
      end
      # break 'ahaha' if tac[1] == 'S' # 暫定脱出
      # break 'ihihi' if i == 3000 # 暫定脱出
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
