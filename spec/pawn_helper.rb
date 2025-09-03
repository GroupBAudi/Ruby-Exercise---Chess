require '../lib/piece/pawn.rb'
require '../lib/board.rb'
require '../lib/player.rb'

describe Pawn do
  describe '#valid_moves' do
    context 'when pawn color is white and at default position' do
      let(:board) { Board.new }
      let(:position) { [6, 1] } # second bottom row
      subject(:pawn) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = pawn
      end
        
      it 'returns valid forward moves within board boundaries' do
        moves = pawn.valid_moves(board)
        
        expect(moves).to include([5, 1]) # normal move
        expect(moves).to include([4, 1]) # double move
      end

      it 'returns valid forward moves within board boundaries and not obstructed' do
        board.grid[6][1] = Pawn.new(:black, [6, 1])
        moves = pawn.valid_moves(board)
        
        expect(moves).to include([5, 1]) # normal move
        expect(moves).to include([4, 1]) # double move
      end

      it 'returns valid one forward move when obstructed' do
        board.grid[4][1] = Pawn.new(:white, [4, 1])

        moves = pawn.valid_moves(board)

        expect(moves).to include([5, 1])
        expect(moves).to_not include([4, 1]) # obstructed by another pawn
      end
      
      it 'returns no valid moves when obstructed' do
        board.grid[5][1] = Pawn.new(:white, [5, 1])

        moves = pawn.valid_moves(board)

        expect(moves).to eq([])
      end

      it 'returns only one step move when already moved' do
        board.grid[4][1] = Pawn.new(:white, [4, 1])
        another_pawn = board.grid[4][1]

        expect(another_pawn.valid_moves(board)).to include([3, 1])
      end
    end

    context 'when pawn color is black' do
      let(:board) { Board.new }
      let(:position) { [1, 1] } # second top row
      subject(:pawn) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = pawn
      end
        
      it 'returns valid forward moves within board boundaries' do
        moves = pawn.valid_moves(board)
        
        expect(moves).to include([2, 1]) # normal move
        expect(moves).to include([3, 1]) # double move
      end

      it 'returns valid one forward move when obstructed' do
        board.grid[3][1] = Pawn.new(:black, position)

        moves = pawn.valid_moves(board)

        expect(moves).to include([2, 1]) # normal
        expect(moves).to_not include([3, 1]) # obstructed
      end
      
      it 'returns no valid moves when obstructed' do
        board.grid[2][1] = Pawn.new(:black, position)

        moves = pawn.valid_moves(board)

        expect(moves).to eq([])
      end

      it 'returns only one step move when already moved' do
        board.grid[2][1] = Pawn.new(:black, [2, 1])
        another_pawn = board.grid[2][1]

        expect(another_pawn.valid_moves(board)).to include([3, 1])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when pawn is white' do
      let(:board) { Board.new }
      let(:position_white) { [4, 3] }
      subject(:pawn_white) { described_class.new(:white, position_white) }
      
      before do
        row, col = position_white
        board.grid[row][col] = pawn_white
      end
      
      it 'returns a move that allows for capture' do
        position_black = [3, 4]
        row, col = position_black 
        board.grid[row][col] = Pawn.new(:black, position_black)
        moves = pawn_white.valid_capture_moves(board)

        expect(moves).to include([3, 4])
      end

      it 'returns two moves when there are two pieces diagonal against the pawn' do
        position_black = [3, 2]
        row, col = position_black 
        board.grid[row][col] = Pawn.new(:black, position_black)
        moves = pawn_white.valid_capture_moves(board)

        expect(moves).to include([3, 2])
      end

      it 'returns no valid capture moves when opposing pawn is not diagonally placed' do
        position_black = [3, 3]
        row, col = position_black 
        board.grid[row][col] = Pawn.new(:black, position_black)
        moves = pawn_white.valid_capture_moves(board)

        expect(moves).to eq([])
      end

      it 'does not cannibalize same team' do
        position_white = [3, 4] 
        row, col = position_white
        board.grid[row][col] = Pawn.new(:white, position_white)
        moves = pawn_white.valid_capture_moves(board)

        expect(moves).to_not include([3, 4])
      end
    end
    
    context 'when pawn is black' do
      let(:board) { Board.new }
      let(:position_black) { [3, 5] }
      subject(:pawn_black) { described_class.new(:black, position_black) }
      
      before do
        row, col = position_black
        board.grid[row][col] = pawn_black
      end
      
      it 'shows a move that allows for capture' do
        position_white = [4, 4] 
        row, col = position_white 
        board.grid[row][col] = Pawn.new(:white, position_white)
        moves = pawn_black.valid_capture_moves(board)

        expect(moves).to include([4, 4])
      end

      it 'shows two moves when there are two pieces diagonal against the pawn' do
        position_white = [4, 6] 
        row, col = position_white
        board.grid[row][col] = Pawn.new(:white, position_white)
        moves = pawn_black.valid_capture_moves(board)

        expect(moves).to include([4, 6])
      end

      it 'returns no valid capture moves when opposing pawn is not diagonally placed' do
        position_white = [3, 3]
        row, col = position_white 
        board.grid[row][col] = Pawn.new(:white, position_white)
        moves = pawn_black.valid_capture_moves(board)

        expect(moves).to eq([])
      end

      it 'does not cannibalize same team' do
        position_black = [4, 6]
        row, col = position_black 
        board.grid[row][col] = Pawn.new(:black, position_black)
        moves = pawn_black.valid_capture_moves(board)

        expect(moves).to_not include([4, 6])
      end
    end
  end

  describe '#en_passant' do
    context 'when pawn is white' do
      let(:board) { Board.new }
      let(:player_one) { Player.new("Player One", :white) }
      subject(:pawn_white) { described_class.new(:white, [6, 1]) }

      before do
        board.grid[6][1] = pawn_white
      end

      it 'sets en_passant flag as true if move two steps' do
        target_position = [4, 1]
        board.move_piece(player_one, [6, 1], target_position)
        expect(pawn_white.en_passant).to eq(true)
      end

      it 'sets en passant flag as false if move one step' do
        target_position = [5, 1]
        board.move_piece(player_one, [6, 1], target_position)
        expect(pawn_white.en_passant).to eq(false)
      end

      it 'sets en passant flag as false if move two different steps' do
        board.move_piece(player_one, [6, 1], [5, 1])
        board.move_piece(player_one, [5, 1], [4, 1])
        expect(pawn_white.en_passant).to eq(false)
      end
    end

    context 'when pawn is black' do
      let(:board) { Board.new }
      let(:player_one) { Player.new("Player One", :black) }
      subject(:pawn_black) { described_class.new(:black, [1, 2]) }

      before do
        board.grid[1][2] = pawn_black
      end

      it 'sets en_passant flag as true if move two steps' do
        target_position = [3, 2]
        board.move_piece(player_one, [1, 2], target_position)
        expect(pawn_black.en_passant).to eq(true)
      end

      it 'sets en passant flag as false if move one step' do
        target_position = [2, 2]
        board.move_piece(player_one, [1, 2], target_position)
        expect(pawn_black.en_passant).to eq(false)
      end

      it 'sets en passant flag as false if move two different steps' do
        board.move_piece(player_one, [1, 2], [2, 2])
        board.move_piece(player_one, [2, 2], [3, 2])
        expect(pawn_black.en_passant).to eq(false)
      end
    end
  end

  describe '#valid_enpassant_move' do
    context 'when pawn is white' do
      let(:board) { Board.new }
      let(:player_one) { Player.new("Player One", :white) }
      let(:player_two) { Player.new("Player Two", :black) }
      subject(:pawn_white) { described_class.new(:white, [3, 1]) }

      before do
        board.grid[3][1] = pawn_white
      end

      it 'returns a move that allows for en passant if pawn is at right' do
        pawn_black = Pawn.new(:black, [1, 2])
        board.grid[1][2] = pawn_black
        board.move_piece(player_two, [1, 2], [3, 2]) # moves two step
        moves = pawn_white.valid_enpassant_move(board)

        expect(moves).to include([2, 2])
      end

      it 'returns a move that allows for en passant if pawn is at left' do
        pawn_black = Pawn.new(:black, [1, 0])
        board.grid[1][0] = pawn_black
        board.move_piece(player_two, [1, 0], [3, 0]) # moves two step
        moves = pawn_white.valid_enpassant_move(board)

        expect(moves).to include([2, 0])
      end
    end

    context 'when pawn is black' do
      let(:board) { Board.new }
      let(:player_one) { Player.new("Player One", :white) }
      let(:player_two) { Player.new("Player Two", :black) }
      subject(:pawn_black) { described_class.new(:black, [4, 4]) }

      before do
        board.grid[4][4] = pawn_black
      end

      it 'returns a move that allows for en passant if pawn is at right' do
        pawn_white = Pawn.new(:white, [6, 5])
        board.grid[6][5] = pawn_white
        board.move_piece(player_two, [6, 5], [4, 5]) # moves two step
        moves = pawn_black.valid_enpassant_move(board)

        expect(moves).to include([5, 5])
      end

      it 'returns a move that allows for en passant if pawn is at left' do
        pawn_white = Pawn.new(:white, [6, 3])
        board.grid[6][3] = pawn_white
        board.move_piece(player_two, [6, 3], [4, 3]) # moves two step
        moves = pawn_black.valid_enpassant_move(board)

        expect(moves).to include([5, 3])
      end
    end
  end
end