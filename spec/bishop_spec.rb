require '../lib/pieces/bishop.rb'
require '../lib/board.rb'
require '../lib/player.rb'

describe Bishop do
  describe '#valid_moves' do
    context 'when there are no blockers' do
      let(:position) { [4, 4] } # middle
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end

      it 'returns diagonal moves' do
        moves = bishop.valid_moves(board)
        
        directions = [
          [1, 1],
          [1, -1],
          [-1, 1],
          [-1, -1]
        ]

        expected = []
        directions.each do |dx, dy|
          (1..7).each do |i|
            expected << [4 + i * dx, 4 + i * dy]
          end
        end
        expected = expected.reject { |x, y| x < 0 || x > 7 || y < 0 || y > 7 }

        expect(moves.sort).to eq(expected.sort)
      end
    end

    context 'when a friendly piece blocks the bishop' do

      let(:position) { [4, 1] } # b4
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end

      it 'stops before the friendly piece' do
        board.grid[6][3] = Bishop.new(:white, [6, 3]) # d2

        moves = bishop.valid_moves(board)

        expect(moves).to_not include([6, 3])
      end
    end

    context 'when an enemy piece blocks the bishop' do
      let(:position) { [3, 4] } # e5
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end
      
      it 'stops movement at the enemy piece' do
        board.grid[6][1] = Bishop.new(:white, [6, 1]) # b2

        moves = bishop.valid_moves(board)

        expect(moves).to_not include([6, 1])
      end

      it 'has capture movement at the enemy piece' do
        board.grid[6][1] = Bishop.new(:white, [6, 1]) # b2

        moves = bishop.valid_capture_moves(board)

        expect(moves).to include([6, 1])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when an enemy is in each direction' do
      let(:position) { [4, 4] } # e4
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end

      it 'returns the enemies as valid captures' do
        board.grid[6][2] = Bishop.new(:black, [6, 2]) # c2
        board.grid[6][6] = Bishop.new(:black, [6, 6]) # g2
        board.grid[2][2] = Bishop.new(:black, [2, 2]) # c6
        board.grid[2][6] = Bishop.new(:black, [2, 6]) # g6

        expected_capture = [[6, 2], [6, 6], [2, 2], [2, 6]].sort

        available_capture_moves = bishop.valid_capture_moves(board).sort

        expect(available_capture_moves).to eq(expected_capture)
      end
    end

    context 'when a friendly piece is in the way' do
      let(:position) { [4, 7] } # h4
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end

      it 'does not return the friendly piece' do
        board.grid[1][4] = Rook.new(:black, [1, 4]) # e7

        available_capture_moves = bishop.valid_capture_moves(board)

        expect(available_capture_moves).to eq([])
      end
    end

    context 'when another enemy is behind an enemy' do
      let(:position) { [4, 7] } # h4
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end

      it 'only returns the first enemy' do
        board.grid[2][5] = Bishop.new(:white, [2, 5]) # f6
        board.grid[1][4] = Bishop.new(:white, [1, 4]) # e7

        available_capture_moves = bishop.valid_capture_moves(board)

        expect(available_capture_moves).to eq([[2, 5]])
      end
    end

    context 'when an enemy is behind a friendly piece' do
      let(:position) { [4, 7] } # h4
      let(:board) { Board.new }
      subject(:bishop) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = bishop
      end

      it 'does not return the enemy' do
        board.grid[2][5] = Bishop.new(:black, [2, 5]) # f6
        board.grid[1][4] = Bishop.new(:white, [1, 4]) # e7

        available_capture_moves = bishop.valid_capture_moves(board)

        expect(available_capture_moves).to_not include([1, 4])
      end
    end
  end
end