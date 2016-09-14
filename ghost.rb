require 'set'
require 'byebug'
DICTIONARY = IO.readlines('dictionary.txt').map(&:chomp)
class Match
  attr_accessor :result, :players

  def initialize(num_of_players)
    raise "Not enough players" if num_of_players < 2
    create_players(num_of_players)


  end

  def create_players(num)
    @players = []

    num.times do
      puts "Name?"
      name = gets.chomp
      @players << Player.new(name)
    end
    @players << ComputerPlayer.new("Watson")

  end

  def play_match
    until @players.length == 1
      Game.new(@players, self).run
      display_standings
    end
  end

  def record(loser)
    loser.result += 1
  end

  def display_standings
    string = " GHOST"
    @players.each do |player|
      puts "#{player.name}:#{string[0..player.result]}"
    end
  end

end

class Game
  attr_reader :fragment

  def initialize(players, match)
    @players = players
    @fragment = ""
    @match = match
  end

  def run
      until over?
        play_round
      end
      announce_winner
      @match.record(@players[1])
  end

  def announce_winner
    puts "#{@players[1].name} loses"
  end

  def play_round
    puts "#{@players[0].name} to play"
    @fragment += @players[0].guess(@fragment, @players)
    next_player!
    puts @fragment
  end

  def next_player!
    @players.rotate!(-1)
  end

  def over?
    DICTIONARY.include?(@fragment)
  end

end

class Player
  attr_reader :name
  attr_accessor :result

  def initialize(name)
    @name = name
    @result = 0
  end

  def guess(fragment, players)
    letter = ""
    loop do
      puts "Give a letter"
      letter = gets.chomp
      attempt = fragment + letter
      break if letter.match(/[a-zA-Z]/) && DICTIONARY.any? { |word| word[0..attempt.length - 1] == attempt }
    end
    letter
  end

end

class ComputerPlayer
  attr_reader :name
  attr_accessor :result

  def initialize(name)
    @dictionary = DICTIONARY
    @name = name
    @result = 0
  end

  def count_good_words(letter, frag_length, num_of_players)
    counter = 0
    @dictionary.each do |word|
      counter += 1 if word[frag_length] == letter && (word.length - frag_length) % num_of_players == 0
    end
    counter
  end

  def guess(fragment, players)

    @dictionary = @dictionary.select { |word| word[0..fragment.length - 1] == fragment }
    best_letter = ""
    best_good_word_count = 0
    ('a'..'z').each do |letter|
      good_word_count = count_good_words(letter, fragment.length, players.length)
      if good_word_count > best_good_word_count
        best_letter = letter
        best_good_word_count = good_word_count
      end
    end
    best_letter
  end

end

if $PROGRAM_NAME == __FILE__
  Match.new(2).play_match
end
