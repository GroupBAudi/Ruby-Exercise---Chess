require '../lib/pieces/queen.rb'
require '../lib/board.rb'
require '../lib/player.rb'

describe Queen do
  describe '#valid_moves' do
    context 'when there are no blockers' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'returns horizontal, vertical, and diagonal moves' do
        moves = queen.valid_moves(board)

        directions = [
          [1, 0],
          [0, 1],
          [-1, 0],
          [0, -1],
          [1, 1],
          [-1, 1],
          [1, -1],
          [-1, -1]
        ]

        expected = []

        directions.each do |dx, dy|
          (1..7).each do |i|
            expected << [4 + i * dx, 4 + i * dy]
          end
        end

        expected = expected.reject do |x, y|
          x < 0 || x > 7 || y < 0 || y > 7
        end

        expect(moves.sort).to eq(expected.sort)
      end
    end

    context 'when friendly pieces block the queen' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'stops before friendly pieces on straight and diagonal paths' do
        board.grid[4][6] = Rook.new(:white, [4, 6])
        board.grid[6][6] = Bishop.new(:white, [6, 6])

        moves = queen.valid_moves(board)

        expect(moves).to_not include([4, 6])
        expect(moves).to_not include([6, 6])
      end
    end

    context 'when enemy pieces block the queen' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'stops movement at enemies on straight and diagonal paths' do
        board.grid[4][6] = Rook.new(:white, [4, 6])
        board.grid[6][6] = Bishop.new(:white, [6, 6])

        moves = queen.valid_moves(board)

        expect(moves).to_not include([4, 6])
        expect(moves).to_not include([6, 6])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when an enemy is in each direction' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'returns enemies from all eight directions' do
        enemies = [
          [6, 4], # down
          [4, 6], # right
          [2, 4], # up
          [4, 2], # left
          [6, 6], # down-right
          [2, 6], # up-right
          [6, 2], # down-left
          [2, 2]  # up-left
        ]

        enemies.each do |row, col|
          board.grid[row][col] = Queen.new(:black, [row, col])
        end

        available_capture_moves = queen.valid_capture_moves(board)

        expect(available_capture_moves.sort).to eq(enemies.sort)
      end
    end

    context 'when friendly pieces are in the way' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'does not return friendly pieces' do
        board.grid[4][2] = Rook.new(:black, [4, 2])
        board.grid[2][2] = Bishop.new(:black, [2, 2])

        available_capture_moves = queen.valid_capture_moves(board)

        expect(available_capture_moves).to eq([])
      end
    end

    context 'when another enemy is behind an enemy' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'only returns the first enemy on each path' do
        # straight
        board.grid[4][2] = Rook.new(:white, [4, 2])
        board.grid[4][1] = Rook.new(:white, [4, 1])

        # diagonal
        board.grid[2][2] = Bishop.new(:white, [2, 2])
        board.grid[1][1] = Bishop.new(:white, [1, 1])

        available_capture_moves = queen.valid_capture_moves(board)

        expect(available_capture_moves.sort).to eq([[4, 2], [2, 2]].sort)
      end
    end

    context 'when an enemy is behind a friendly piece' do
      let(:position) { [4, 4] }
      let(:board) { Board.new }
      subject(:queen) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = queen
      end

      it 'does not return enemies behind friendly pieces' do
        # straight
        board.grid[4][2] = Rook.new(:black, [4, 2])
        board.grid[4][1] = Rook.new(:white, [4, 1])

        # diagonal
        board.grid[2][2] = Bishop.new(:black, [2, 2])
        board.grid[1][1] = Bishop.new(:white, [1, 1])

        available_capture_moves = queen.valid_capture_moves(board)

        expect(available_capture_moves).to_not include([4, 1])
        expect(available_capture_moves).to_not include([1, 1])
      end
    end
  end
end