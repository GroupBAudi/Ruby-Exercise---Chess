# frozen_string_literal: true

# frozen_string_literal: true

require_relative 'lib/game'

game = if File.exist?(SaveGame::SAVE_FILE)
         puts 'Save file detected. Load game? (Y/n)'
         answer = gets.chomp.downcase

         answer.empty? || answer == 'y' ? SaveGame.load_state : Game.new
       else
         Game.new
       end

Signal.trap('INT') do
  raise Interrupt
end

begin
  game.play_turn
rescue Interrupt
  puts "\nGame interrupted. Saving..."
  game.save_state
  puts "Game saved!"
end
