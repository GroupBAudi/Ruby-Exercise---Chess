require '../lib/pieces/rook.rb'
require '../lib/board.rb'
require '../lib/player.rb'

describe Rook do
  describe '#valid_moves' do
    context 'when there are no blockers' do
      let(:position) { [4, 4] } # middle
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end
      it 'returns horizontal and vertical moves' do
        moves = rook.valid_moves(board).sort
        
        expected = []
        (0..7).reject { |x|  x == 4 }.each do |x|
          expected << [4, x]
          expected << [x, 4]
        end

        expect(moves).to eq(expected.sort)
      end
    end

    context 'when a friendly piece blocks the rook' do

      let(:position) { [4, 1] } # b4
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end

      it 'stops before the friendly piece' do
        board.grid[4][3] = Rook.new(:white, [4, 3]) # d4

        moves = rook.valid_moves(board).sort

        expect(moves).to_not include([4, 3])
      end
    end

    context 'when an enemy piece blocks the rook' do
      let(:position) { [3, 4] } # e5
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end
      
      it 'stops movement at the enemy piece' do
        board.grid[6][4] = Rook.new(:white, [6, 4]) # e2

        vertical_moves = rook.valid_moves(board).sort

        expect(vertical_moves).to_not include([6, 4])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when an enemy is in each direction' do
      let(:position) { [4, 4] } # e4
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end

      it 'returns the enemies as valid captures' do
        board.grid[4][2] = Rook.new(:black, [4, 2]) # c4
        board.grid[4][6] = Rook.new(:black, [4, 6]) # g4
        board.grid[6][4] = Rook.new(:black, [6, 4]) # e2
        board.grid[2][4] = Rook.new(:black, [2, 4]) # e6

        expected_capture = [[4, 2], [4, 6], [6, 4], [2, 4]].sort

        available_capture_moves = rook.valid_capture_moves(board).sort

        expect(available_capture_moves).to eq(expected_capture)
      end
    end

    context 'when a friendly piece is in the way' do
      let(:position) { [4, 7] } # h4
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end

      it 'does not return the friendly piece' do
        board.grid[4][1] = Rook.new(:black, [4, 1])

        available_capture_moves = rook.valid_capture_moves(board).sort

        expect(available_capture_moves).to eq([])
      end
    end

    context 'when another enemy is behind an enemy' do
      let(:position) { [4, 7] } # h4
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end

      it 'only returns the first enemy' do
        board.grid[4][4] = Rook.new(:white, [4, 4]) # e4
        board.grid[4][1] = Rook.new(:white, [4, 1]) # b4

        available_capture_moves = rook.valid_capture_moves(board).sort

        expect(available_capture_moves).to eq([[4, 4]])
      end
    end

    context 'when an enemy is behind a friendly piece' do
      let(:position) { [4, 7] } # h4
      let(:board) { Board.new }
      subject(:rook) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = rook
      end

      it 'does not return the enemy' do
        board.grid[4][4] = Rook.new(:black, [4, 4]) # e4
        board.grid[4][1] = Rook.new(:white, [4, 1]) # b4

        available_capture_moves = rook.valid_capture_moves(board)

        expect(available_capture_moves).to_not include([4, 1])
      end
    end
  end
end