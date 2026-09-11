require_relative '../lib/pieces/pawn'
require_relative '../lib/board'

describe Pawn do
  describe '#valid_moves' do
    context 'when pawn color is white and at default position' do
      let(:board) { Board.new }
      let(:position) { [6, 1] }
      subject(:pawn) { described_class.new(:white, position) }

      before do
        row, col = position
        board.grid[row][col] = pawn
      end

      it 'returns valid forward moves within board boundaries' do
        moves = pawn.valid_moves(board)

        expect(moves).to include([5, 1])
        expect(moves).to include([4, 1])
      end

      it 'returns valid forward moves when its own starting square is occupied by itself' do
        moves = pawn.valid_moves(board)

        expect(moves).to include([5, 1])
        expect(moves).to include([4, 1])
      end

      it 'returns only one forward move when the two-step destination is obstructed' do
        board.grid[4][1] = Pawn.new(:white, [4, 1])

        moves = pawn.valid_moves(board)

        expect(moves).to include([5, 1])
        expect(moves).not_to include([4, 1])
      end

      it 'returns no valid moves when immediately obstructed' do
        board.grid[5][1] = Pawn.new(:white, [5, 1])

        moves = pawn.valid_moves(board)

        expect(moves).to eq([])
      end

      it 'returns only one step when no longer at its default position' do
        another_pawn = Pawn.new(:white, [4, 1])
        board.grid[4][1] = another_pawn

        expect(another_pawn.valid_moves(board)).to include([3, 1])
        expect(another_pawn.valid_moves(board)).not_to include([2, 1])
      end
    end

    context 'when pawn color is black' do
      let(:board) { Board.new }
      let(:position) { [1, 1] }
      subject(:pawn) { described_class.new(:black, position) }

      before do
        row, col = position
        board.grid[row][col] = pawn
      end

      it 'returns valid forward moves within board boundaries' do
        moves = pawn.valid_moves(board)

        expect(moves).to include([2, 1])
        expect(moves).to include([3, 1])
      end

      it 'returns only one forward move when the two-step destination is obstructed' do
        board.grid[3][1] = Pawn.new(:black, [3, 1])

        moves = pawn.valid_moves(board)

        expect(moves).to include([2, 1])
        expect(moves).not_to include([3, 1])
      end

      it 'returns no valid moves when immediately obstructed' do
        board.grid[2][1] = Pawn.new(:black, [2, 1])

        moves = pawn.valid_moves(board)

        expect(moves).to eq([])
      end

      it 'returns only one step when no longer at its default position' do
        another_pawn = Pawn.new(:black, [2, 1])
        board.grid[2][1] = another_pawn

        expect(another_pawn.valid_moves(board)).to include([3, 1])
        expect(another_pawn.valid_moves(board)).not_to include([4, 1])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when pawn is white' do
      let(:board) { Board.new }
      let(:position) { [4, 3] }
      subject(:pawn) { described_class.new(:white, position) }

      before do
        board.grid[4][3] = pawn
      end

      it 'allows capture diagonally to the right' do
        board.grid[3][4] = Pawn.new(:black, [3, 4])

        expect(pawn.valid_capture_moves(board)).to include([3, 4])
      end

      it 'allows capture diagonally to the left' do
        board.grid[3][2] = Pawn.new(:black, [3, 2])

        expect(pawn.valid_capture_moves(board)).to include([3, 2])
      end

      it 'does not capture a piece directly ahead' do
        board.grid[3][3] = Pawn.new(:black, [3, 3])

        expect(pawn.valid_capture_moves(board)).to eq([])
      end

      it 'does not capture a friendly piece' do
        board.grid[3][4] = Pawn.new(:white, [3, 4])

        expect(pawn.valid_capture_moves(board)).not_to include([3, 4])
      end
    end

    context 'when pawn is black' do
      let(:board) { Board.new }
      let(:position) { [3, 5] }
      subject(:pawn) { described_class.new(:black, position) }

      before do
        board.grid[3][5] = pawn
      end

      it 'allows capture diagonally to the left' do
        board.grid[4][4] = Pawn.new(:white, [4, 4])

        expect(pawn.valid_capture_moves(board)).to include([4, 4])
      end

      it 'allows capture diagonally to the right' do
        board.grid[4][6] = Pawn.new(:white, [4, 6])

        expect(pawn.valid_capture_moves(board)).to include([4, 6])
      end

      it 'does not capture a piece directly ahead' do
        board.grid[4][5] = Pawn.new(:white, [4, 5])

        expect(pawn.valid_capture_moves(board)).to eq([])
      end

      it 'does not capture a friendly piece' do
        board.grid[4][6] = Pawn.new(:black, [4, 6])

        expect(pawn.valid_capture_moves(board)).not_to include([4, 6])
      end
    end
  end

  describe '#en_passant?' do
    context 'when pawn is white' do
      let(:board) { Board.new }
      subject(:pawn) { described_class.new(:white, [6, 1]) }

      before do
        board.grid[6][1] = pawn
      end

      it 'sets en_passant to true after moving two squares' do
        board.move_piece([6, 1], [4, 1])

        expect(pawn.en_passant).to eq(true)
      end

      it 'sets en_passant to false after moving one square' do
        board.move_piece([6, 1], [5, 1])

        expect(pawn.en_passant).to eq(false)
      end

      it 'does not set en_passant after two separate one-square moves' do
        board.move_piece([6, 1], [5, 1])
        board.move_piece([5, 1], [4, 1])

        expect(pawn.en_passant).to eq(false)
      end
    end

    context 'when pawn is black' do
      let(:board) { Board.new }
      subject(:pawn) { described_class.new(:black, [1, 2]) }

      before do
        board.grid[1][2] = pawn
      end

      it 'sets en_passant to true after moving two squares' do
        board.move_piece([1, 2], [3, 2])

        expect(pawn.en_passant).to eq(true)
      end

      it 'sets en_passant to false after moving one square' do
        board.move_piece([1, 2], [2, 2])

        expect(pawn.en_passant).to eq(false)
      end

      it 'does not set en_passant after two separate one-square moves' do
        board.move_piece([1, 2], [2, 2])
        board.move_piece([2, 2], [3, 2])

        expect(pawn.en_passant).to eq(false)
      end
    end
  end

  describe '#valid_en_passant_move' do
    context 'when pawn is white' do
      let(:board) { Board.new }
      subject(:pawn_white) { described_class.new(:white, [3, 1]) }

      before do
        board.grid[3][1] = pawn_white
      end

      it 'allows en passant against an eligible pawn on the right' do
        pawn_black = Pawn.new(:black, [1, 2])
        board.grid[1][2] = pawn_black

        board.move_piece([1, 2], [3, 2])

        expect(pawn_white.valid_en_passant_move(board)).to include([2, 2])
      end

      it 'allows en passant against an eligible pawn on the left' do
        pawn_black = Pawn.new(:black, [1, 0])
        board.grid[1][0] = pawn_black

        board.move_piece([1, 0], [3, 0])

        expect(pawn_white.valid_en_passant_move(board)).to include([2, 0])
      end
    end

    context 'when pawn is black' do
      let(:board) { Board.new }
      subject(:pawn_black) { described_class.new(:black, [4, 4]) }

      before do
        board.grid[4][4] = pawn_black
      end

      it 'allows en passant against an eligible pawn on the right' do
        pawn_white = Pawn.new(:white, [6, 5])
        board.grid[6][5] = pawn_white

        board.move_piece([6, 5], [4, 5])

        expect(pawn_black.valid_en_passant_move(board)).to include([5, 5])
      end

      it 'allows en passant against an eligible pawn on the left' do
        pawn_white = Pawn.new(:white, [6, 3])
        board.grid[6][3] = pawn_white

        board.move_piece([6, 3], [4, 3])

        expect(pawn_black.valid_en_passant_move(board)).to include([5, 3])
      end
    end
  end
end