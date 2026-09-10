require '../lib/pieces/knight.rb'
require '../lib/pieces/pawn.rb'
require '../lib/pieces/queen.rb'
require '../lib/board.rb'
require '../lib/player.rb'

describe Knight do
  describe '#valid_moves' do
    context 'when the knight is near the center' do
      let(:position) { [4, 4] } # middle
      let(:board) { Board.new }
      subject(:knight) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = knight
      end

      it 'returns all 8 L-shaped destinations' do
        expected = [
            [6, 5], [2, 5], [6, 3], [2, 3],
            [5, 6], [3, 6], [5, 2], [3, 2]
          ]

        moves = knight.valid_moves(board)

        expect(moves).to match_array(expected)
      end
    end

    context 'when the knight is near the board boundary' do
      let(:position) { [7, 7] } # h1
      let(:board) { Board.new }
      subject(:knight) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = knight
      end

      it 'excludes destinations outside the board' do
        moves = knight.valid_moves(board)
        expected = [[6, 5], [5, 6]]

        expect(moves).to match_array(expected)
      end  
    end

    context 'when a destination is occupied' do
      let(:position) { [6, 6] } # g2
      let(:board) { Board.new }
      subject(:knight) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = knight
      end

      it 'excludes occupied destinations from normal moves' do
        board.grid[4][7] = Knight.new(:white, [4, 7])
        moves = knight.valid_moves(board)

        expect(moves).to_not include([4, 7])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when an enemy occupies a valid destination' do
      let(:position) { [4, 4] } # middle
      let(:board) { Board.new }
      subject(:knight) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = knight
      end

      it 'includes that destination' do
        board.grid[6][3] = Pawn.new(:black, [6, 3])
        capture_move = knight.valid_capture_moves(board)

        expect(capture_move).to include([6, 3])
      end
    end

    context 'when an ally occupies a valid destination' do
      let(:position) { [2, 5] } # f6
      let(:board) { Board.new }
      subject(:knight) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = knight
      end

      it 'excludes that destination' do
        board.grid[4][4] = Queen.new(:black, [4, 4]) # e4
        capture_move = knight.valid_capture_moves(board)

        expect(capture_move).to_not include([4, 4])
      end
    end

    context 'when the destination is empty' do
      let(:position) { [2, 5] } # f6
      let(:board) { Board.new }
      subject(:knight) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = knight
      end

      it 'does not consider it a capture' do
        capture_move = knight.valid_capture_moves(board)

        expect(capture_move).to eq([])
      end
    end
  end
end