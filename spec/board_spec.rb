require '../lib/board.rb'
require '../lib/player.rb'
require '../lib/pieces/pawn.rb'

# RSpec rules relevant to THESE tests:

# 1. Every `it` starts independently.
#    Nothing moved in another `it` remains moved.

# 2. `before` runs again before every `it`.

# 3. `let(:pawn)` gives each example access to its own pawn.

# 4. A local variable created inside `before` isn't visible inside `it`.

# 5. One `it` should contain the complete sequence needed
#    to reach the state it asserts.

describe Board do
  describe 'pawn en passant eligibility' do
    subject(:board) { described_class.new }
    context 'when pawn is white' do
      context 'when pawn moves two squares from its starting position' do
        let(:pawn_white) { Pawn.new(:white, [6, 1]) } # b2

        before do
          board.grid[6][1] = pawn_white
          allow($stdout).to receive(:puts)
        end

        it 'said pawn becomes en-passant eligible' do
          board.move_piece([6, 1], [4, 1])
          expect(pawn_white.en_passant).to be true
        end

        it 'en-passant flag expires if it moves again' do
          # fix add
          board.move_piece([6, 1], [4, 1])
          board.move_piece([4, 1], [3, 1])
          expect(pawn_white.en_passant).to be false
        end
      end
    end
  
    context 'when pawn is black' do
      subject(:board) { described_class.new }

      context 'when pawn moves two squares from its starting position' do
        let(:pawn_black) { Pawn.new(:black, [1, 4]) } # b4

        before do
          board.grid[1][4] = pawn_black
          allow($stdout).to receive(:puts)
        end

        it 'said pawn becomes en-passant eligible' do
          board.move_piece([1, 4], [3, 4])
          expect(pawn_black.en_passant).to be true
        end

        it 'en-passant flag expires if it moves again' do
          board.move_piece([1, 4], [3, 4])
          board.move_piece([3, 4], [4, 4])
          expect(pawn_black.en_passant).to be false
        end
      end
    end
  end

  describe 'pawn en passant capture' do
    subject(:board) { described_class.new }
    context 'when pawn is white' do
      let(:pawn_white) { Pawn.new(:white, [3, 1]) } #b5

      before do
        board.grid[3][1] = pawn_white
        allow($stdout).to receive(:puts)
      end

      it '(c5) returns one en passant move if either black pawn move two steps' do
        pawn_black = Pawn.new(:black, [1, 2])
        board.grid[1][2] = pawn_black
        board.move_piece([1, 2], [3, 2])
        expect(pawn_white.valid_en_passant_move(board)). to include([2, 2])
      end

      it '(a5) returns one en passant move if either black pawn move two steps' do
        pawn_black = Pawn.new(:black, [1, 0])
        board.grid[1][0] = pawn_black
        board.move_piece([1, 0], [3, 0])
        expect(pawn_white.valid_en_passant_move(board)). to include([2, 0])
      end

      it 'no en passant capture available if other pieces moved' do
        pawn_black = Pawn.new(:black, [1, 0])
        board.grid[1][0] = pawn_black
        board.move_piece([1, 0], [3, 0])
        pawn = Pawn.new(:white, [6, 3])
        board.grid[6][3] = pawn
        board.move_piece([6, 3], [5, 3])
        expect(pawn_white.valid_en_passant_move(board)).to be_empty
      end
    end

    context 'when pawn is black' do
      let(:pawn_black) { Pawn.new(:black, [4, 4]) } # b4
      subject(:board) { described_class.new }

      before do
        board.grid[4][4] = pawn_black
        allow($stdout).to receive(:puts)
      end

      it '(f4) returns one en passant move if either white pawn move two steps' do
        pawn_white = Pawn.new(:white, [6, 5])
        board.grid[6][5] = pawn_white
        board.move_piece([6, 5], [4, 5])
        expect(pawn_black.valid_en_passant_move(board)). to include([5, 5])
      end

      it '(d4) returns one en passant move if either black pawn move two steps' do
        pawn_white = Pawn.new(:white, [6, 3])
        board.grid[6][3] = pawn_white
        board.move_piece([6, 3], [4, 3])
        expect(pawn_black.valid_en_passant_move(board)). to include([5, 3])
      end

      it 'no en passant capture available if other pieces moved' do
        pawn_white = Pawn.new(:white, [6, 3])
        board.grid[6][3] = pawn_white
        board.move_piece([6, 3], [4, 3])
        pawn_white = Pawn.new(:white, [6, 2])
        board.grid[6][2] = pawn_white
        board.move_piece([6, 2], [4, 2])
        expect(pawn_black.valid_en_passant_move(board)).to be_empty
      end
    end
  end
  describe 'renderer module' do
    subject(:board) { described_class.new }

    it 'has renderer module' do
      expect(board).to be_a(Renderer)
    end
    
    it 'responds to the #render method' do
      expect(board).to respond_to(:render)
    end 
  end
end