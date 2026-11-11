
require '../lib/game'

describe Game do
  subject(:game) { described_class.new }

  describe '#promotion_available?' do
    context 'when a White Pawn reaches the back rank' do
      let(:pawn) { Pawn.new(:white, [0, 3]) }

      before do
        game.board.grid[0][3] = pawn
        allow(game).to receive(:promotion_prompt).and_return(Queen)
        allow(game).to receive(:puts)
      end

      it 'promotes the Pawn' do
        game.promotion_available?(pawn)

        expect(game.board.piece_at([0, 3])).to be_a(Queen)
      end

      it 'preserves the Pawn color' do
        game.promotion_available?(pawn)

        expect(game.board.piece_at([0, 3]).color).to eq(:white)
      end
    end

    context 'when a Black Pawn reaches the back rank' do
      let(:pawn) { Pawn.new(:black, [7, 3]) }

      before do
        game.board.grid[7][3] = pawn
        allow(game).to receive(:promotion_prompt).and_return(Queen)
        allow(game).to receive(:puts)
      end

      it 'promotes the Pawn' do
        game.promotion_available?(pawn)

        expect(game.board.piece_at([7, 3])).to be_a(Queen)
      end

      it 'preserves the Pawn color' do
        game.promotion_available?(pawn)

        expect(game.board.piece_at([7, 3]).color).to eq(:black)
      end
    end

    context 'when a Pawn has not reached the back rank' do
      let(:pawn) { Pawn.new(:white, [1, 3]) }

      before do
        game.board.grid[1][3] = pawn
      end

      it 'does not promote the Pawn' do
        expect(game).not_to receive(:promotion_prompt)

        game.promotion_available?(pawn)

        expect(game.board.piece_at([1, 3])).to be(pawn)
      end
    end

    context 'when a non-Pawn reaches the back rank' do
      let(:rook) { Rook.new(:white, [0, 3]) }

      before do
        game.board.grid[0][3] = rook
      end

      it 'does not trigger promotion' do
        expect(game).not_to receive(:promotion_prompt)

        game.promotion_available?(rook)

        expect(game.board.piece_at([0, 3])).to be(rook)
      end
    end

    context 'when a Pawn captures an enemy piece on the back rank' do
      let(:pawn) { Pawn.new(:white, [1, 1]) }
      let(:enemy) { Rook.new(:black, [0, 2]) }

      before do
        game.board.grid[1][1] = pawn
        game.board.grid[0][2] = enemy

        allow(game).to receive(:promotion_prompt).and_return(Knight)
        allow(game).to receive(:puts)
      end

      it 'captures the enemy and promotes the Pawn' do
        available_moves = game.board.legal_moves(pawn)

        expect(available_moves).to include([0, 2])

        captured_piece = game.board.move_piece([1, 1], [0, 2])

        game.promotion_available?(pawn)

        expect(captured_piece).to be(enemy)
        expect(game.board.piece_at([0, 2])).to be_a(Knight)
        expect(game.board.piece_at([0, 2]).color).to eq(:white)
        expect(game.board.piece_at([1, 1])).to be_nil
      end
    end
  end

  describe '#promotion_prompt' do
    {
      "0" => Queen,
      "1" => Rook,
      "2" => Knight,
      "3" => Bishop
    }.each do |input, expected_class|

      it "returns #{expected_class} when the player selects #{input}" do
        allow(game).to receive(:gets).and_return("#{input}\n")
        allow(game).to receive(:puts)

        expect(game.promotion_prompt).to be(expected_class)
      end
    end

    it 'rejects invalid input and asks again' do
      allow(game).to receive(:gets).and_return("9\n", "2\n")
      allow(game).to receive(:puts)

      expect(game.promotion_prompt).to be(Knight)
    end
  end
end
