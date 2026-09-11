require_relative '../lib/board'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/bishop'

describe King do
  let(:board) { Board.new }

  describe '#valid_moves' do
    context 'when the king is in the middle of an empty board' do
      it 'returns all eight adjacent squares' do
        king = King.new(:white, [4, 4])
        board.grid[4][4] = king

        expect(king.valid_moves(board)).to match_array([
          [5, 5], [3, 5], [5, 3], [3, 3],
          [5, 4], [4, 5], [3, 4], [4, 3]
        ])
      end
    end

    context 'when the king is at the edge of the board' do
      it 'only returns moves within the board' do
        king = King.new(:white, [7, 7])
        board.grid[7][7] = king

        expect(king.valid_moves(board)).to match_array([
          [6, 6], [6, 7], [7, 6]
        ])
      end
    end

    context 'when a destination is occupied' do
      it 'does not include a friendly occupied square' do
        king = King.new(:white, [4, 4])
        ally = Bishop.new(:white, [5, 5])

        board.grid[4][4] = king
        board.grid[5][5] = ally

        expect(king.valid_moves(board)).not_to include([5, 5])
      end

      it 'does not include an enemy occupied square' do
        king = King.new(:white, [4, 4])
        enemy = Bishop.new(:black, [5, 5])

        board.grid[4][4] = king
        board.grid[5][5] = enemy

        expect(king.valid_moves(board)).not_to include([5, 5])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when an adjacent square contains an enemy piece' do
      it 'includes that square' do
        king = King.new(:white, [4, 4])
        enemy = Bishop.new(:black, [5, 5])

        board.grid[4][4] = king
        board.grid[5][5] = enemy

        expect(king.valid_capture_moves(board)).to include([5, 5])
      end
    end

    context 'when an adjacent square contains a friendly piece' do
      it 'does not include that square' do
        king = King.new(:white, [4, 4])
        ally = Bishop.new(:white, [5, 5])

        board.grid[4][4] = king
        board.grid[5][5] = ally

        expect(king.valid_capture_moves(board)).not_to include([5, 5])
      end
    end

    context 'when an adjacent square is empty' do
      it 'does not include that square' do
        king = King.new(:white, [4, 4])
        board.grid[4][4] = king

        expect(king.valid_capture_moves(board)).not_to include([5, 5])
      end
    end
  end
end