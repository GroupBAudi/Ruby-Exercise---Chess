require '../lib/board.rb'
require '../lib/player.rb'
require '../lib/pieces/pawn.rb'
require '../lib/pieces/pawn'
require '../lib/pieces/rook'
require '../lib/pieces/bishop'
require '../lib/pieces/knight'
require '../lib/pieces/queen'
require '../lib/pieces/king'

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

  describe "#reveal_king?" do
    let(:board) { Board.new }

    context "when another piece blocks the attack after the tested piece" do
      it "returns false" do
        board.grid[0][4] = Queen.new(:white, [0, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[3][4] = Pawn.new(:black, [3, 4])
        board.grid[5][4] = King.new(:black, [5, 4])

        rook = board.piece_at([2, 4])

        expect(board.reveal_king?(rook, :black)).to be false
      end
    end

    context "when another piece blocks the attack before the tested piece" do
      it "returns false" do
        board.grid[0][4] = Queen.new(:white, [0, 4])
        board.grid[1][4] = Pawn.new(:black, [1, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[4][4] = King.new(:black, [4, 4])

        rook = board.piece_at([2, 4])

        expect(board.reveal_king?(rook, :black)).to be false
      end
    end

    context "when another piece blocks a diagonal attack after the tested piece" do
      it "returns false" do
        board.grid[0][0] = Queen.new(:white, [0, 0])
        board.grid[2][2] = Rook.new(:black, [2, 2])
        board.grid[3][3] = Bishop.new(:black, [3, 3])
        board.grid[5][5] = King.new(:black, [5, 5])

        rook = board.piece_at([2, 2])

        expect(board.reveal_king?(rook, :black)).to be false
      end
    end

    context "when the tested piece is the sole blocker" do
      it "returns true despite unrelated pieces elsewhere on the board" do
        board.grid[0][4] = Queen.new(:white, [0, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[4][4] = King.new(:black, [4, 4])

        # Unrelated pieces
        board.grid[1][1] = Pawn.new(:black, [1, 1])
        board.grid[3][7] = Bishop.new(:black, [3, 7])
        board.grid[6][2] = Knight.new(:white, [6, 2])

        rook = board.piece_at([2, 4])

        expect(board.reveal_king?(rook, :black)).to be true
      end
    end

    context "when the tested piece blocks a file attack on its King" do
      it "returns true" do
        board.grid[4][4] = King.new(:black, [4, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[0][4] = Queen.new(:white, [0, 4])

        rook = board.piece_at([2, 4])

        expect(board.reveal_king?(rook, :black)).to be true
      end
    end

    context "when the tested piece blocks a diagonal attack on its King" do
      it "returns true" do
        board.grid[4][4] = King.new(:black, [4, 4])
        board.grid[2][2] = Rook.new(:black, [2, 2])
        board.grid[0][0] = Queen.new(:white, [0, 0])

        rook = board.piece_at([2, 2])

        expect(board.reveal_king?(rook, :black)).to be true
      end
    end

    context "when the attacker is not aligned with the King" do
      it "returns false" do
        board.grid[4][4] = King.new(:black, [4, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[0][0] = Queen.new(:white, [0, 0])

        rook = board.piece_at([2, 4])

        expect(board.reveal_king?(rook, :black)).to be false
      end
    end
  end
  
  describe "#legal_moves" do
    let(:board) { Board.new }

    context "when a piece is the sole blocker between an attacker and its King" do
      it "rejects moves that expose the King" do
        board.grid[0][4] = Queen.new(:white, [0, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[4][4] = King.new(:black, [4, 4])

        rook = board.piece_at([2, 4])
        legal_moves = board.legal_moves(rook)

        expect(legal_moves).not_to include([2, 5])
      end

      it "allows moves that continue blocking the attack" do
        board.grid[0][4] = Queen.new(:white, [0, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[5][4] = King.new(:black, [5, 4])

        rook = board.piece_at([2, 4])
        legal_moves = board.legal_moves(rook)

        expect(legal_moves).to include([3, 4], [4, 4], [1, 4])
      end
    end

    context "when the King is already in check" do
      it "rejects an unrelated move that does not resolve check" do
        board.grid[4][0] = Queen.new(:white, [4, 0])
        board.grid[4][4] = King.new(:black, [4, 4])
        board.grid[7][7] = Rook.new(:black, [7, 7])

        rook = board.piece_at([7, 7])
        legal_moves = board.legal_moves(rook)

        expect(legal_moves).to be_empty
      end

      it "allows a piece to move into the attack line and block check" do
        board.grid[4][0] = Queen.new(:white, [4, 0])
        board.grid[4][4] = King.new(:black, [4, 4])
        board.grid[2][2] = Rook.new(:black, [2, 2])

        rook = board.piece_at([2, 2])
        legal_moves = board.legal_moves(rook)

        expect(legal_moves).to eq([[4, 2]])
      end
    end

    context "when the King is not in check and the piece is not shielding it" do
      it "keeps ordinary legal moves" do
        board.grid[0][1] = Queen.new(:white, [0, 1])
        board.grid[4][4] = King.new(:black, [4, 4])
        board.grid[6][6] = Rook.new(:black, [6, 6])

        rook = board.piece_at([6, 6])
        legal_moves = board.legal_moves(rook)

        expect(legal_moves).to include([6, 5])
      end
    end

    context "after simulating possible moves" do
      it "restores the piece to its original board position" do
        board.grid[0][4] = Queen.new(:white, [0, 4])
        board.grid[2][4] = Rook.new(:black, [2, 4])
        board.grid[4][4] = King.new(:black, [4, 4])

        rook = board.piece_at([2, 4])

        board.legal_moves(rook)

        expect(board.piece_at([2, 4])).to be(rook)
        expect(rook.current_pos).to eq([2, 4])
      end
    end
  end

    describe "endgame conditions" do
    let(:board) { Board.new }

    describe "#checkmate?" do
      context "when the King is in check and no piece can resolve it" do
        it "returns true" do
          board.grid[0][0] = King.new(:black, [0, 0])

          # Other black pieces cannot resolve the check
          board.grid[0][7] = Rook.new(:black, [0, 7])
          board.grid[3][6] = Bishop.new(:black, [3, 6])
          board.grid[6][7] = Knight.new(:black, [6, 7])

          board.grid[1][1] = Queen.new(:white, [1, 1])
          board.grid[2][2] = King.new(:white, [2, 2])

          expect(board.in_check?(:black)).to be true
          expect(board.checkmate?(:black)).to be true
        end
      end

      context "when the King is not in check" do
        it "returns false" do
          board.grid[0][0] = King.new(:black, [0, 0])
          board.grid[0][1] = Rook.new(:black, [0, 1])
          board.grid[1][0] = Pawn.new(:black, [1, 0])
          board.grid[1][1] = Pawn.new(:black, [1, 1])

          board.grid[0][7] = Rook.new(:white, [0, 7])
          board.grid[2][7] = King.new(:white, [2, 7])

          expect(board.in_check?(:black)).to be false
          expect(board.checkmate?(:black)).to be false
        end
      end
    end

    describe "#stalemate?" do
      context "when the King is not in check and the side has no legal moves" do
        it "returns true" do
          board.grid[0][0] = King.new(:black, [0, 0])
          board.grid[1][2] = Queen.new(:white, [1, 2])
          board.grid[2][1] = King.new(:white, [2, 1])

          expect(board.in_check?(:black)).to be false
          expect(board.legal_moves(board.grid[0][0])).to be_empty
          expect(board.stalemate?(:black)).to be true
        end
      end

      context "when the King cannot move but another piece can" do
        it "returns false" do
          board.grid[0][0] = King.new(:black, [0, 0])
          board.grid[1][2] = Queen.new(:white, [1, 2])
          board.grid[2][1] = King.new(:white, [2, 1])
          board.grid[3][7] = Pawn.new(:black, [3, 7])

          king = board.grid[0][0]
          pawn = board.grid[3][7]

          expect(board.in_check?(:black)).to be false
          expect(board.legal_moves(king)).to be_empty
          expect(board.legal_moves(pawn)).not_to be_empty
          expect(board.stalemate?(:black)).to be false
        end
      end
    end
  end
end

