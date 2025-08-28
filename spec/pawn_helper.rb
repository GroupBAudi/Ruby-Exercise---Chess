require '../lib/piece/pawn.rb'
require '../lib/board.rb'

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
end