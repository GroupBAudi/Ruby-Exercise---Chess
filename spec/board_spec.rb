require '../lib/board.rb'
require '../lib/player.rb'
require '../lib/piece/pawn.rb'

describe Board do
  describe '#en_passant_capture' do
    context 'when pawn is white' do
      let(:player_one) { Player.new("Player One", :white) }
      let(:player_two) { Player.new("Player Two", :black) }
      let(:pawn_white) { Pawn.new(:white, [3, 1]) }
      subject(:board) { described_class.new }

      before do
        board.grid[3][1] = pawn_white
        allow($stdout).to receive(:puts)
      end

      it 'returns a move that allows for en passant if pawn is at right' do
        pawn_black = Pawn.new(:black, [1, 2])
        board.grid[1][2] = pawn_black
        board.move_piece(player_two, [1, 2], [3, 2]) # moves two step
        board.move_piece(player_one, [3, 1], [2, 2]) # en passants

        expect(player_one.captured_pieces).to include(pawn_black)
      end

      it 'returns a move that allows for en passant if pawn is at left' do
        pawn_black = Pawn.new(:black, [1, 0])
        board.grid[1][0] = pawn_black
        board.move_piece(player_two, [1, 0], [3, 0]) # moves two step
        board.move_piece(player_one, [3, 1], [2, 0]) # en passants

        expect(player_one.captured_pieces).to include(pawn_black)
      end

      it 'does not return a move if not two step move' do
        pawn_black = Pawn.new(:black, [1, 0])
        board.grid[1][0] = pawn_black
        board.move_piece(player_two, [1, 0], [2, 0]) # moves one step
        board.move_piece(player_two, [2, 0], [3, 0]) # moves another step
        move = board.move_piece(player_one, [3, 1], [2, 0])
        
        expect(move).to eq(false)
      end
    end

    context 'when pawn is black' do
      let(:player_one) { Player.new("Player One", :white) }
      let(:player_two) { Player.new("Player Two", :black) }
      let(:pawn_black) { Pawn.new(:black, [4, 3]) }
      subject(:board) { described_class.new }

      before do
        board.grid[4][3] = pawn_black
        allow($stdout).to receive(:puts)
      end

      it 'returns a move that allows for en passant if pawn is at right' do
        pawn_white = Pawn.new(:white, [6, 4])
        board.grid[6][4] = pawn_white
        board.move_piece(player_one, [6, 4], [4, 4]) # moves two step
        board.move_piece(player_two, [4, 3], [5, 4]) # en passants

        expect(player_two.captured_pieces).to include(pawn_white)
      end

      it 'returns a move that allows for en passant if pawn is at left' do
        pawn_white = Pawn.new(:white, [6, 2])
        board.grid[6][2] = pawn_white
        board.move_piece(player_one, [6, 2], [4, 2]) # moves two step
        board.move_piece(player_two, [4, 3], [5, 2]) # en passants

        expect(player_two.captured_pieces).to include(pawn_white)
      end

      it 'does not return a move if not two step move' do
        pawn_white = Pawn.new(:white, [6, 2])
        board.grid[6][2] = pawn_white
        board.move_piece(player_one, [6, 2], [5, 2]) # moves two step
        board.move_piece(player_one, [5, 2], [4, 2]) # moves two step
        move = board.move_piece(player_two, [4, 3], [5, 2]) # en passants
        
        expect(move).to eq(false)
      end
    end
  end
end
