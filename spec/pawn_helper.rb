require '../lib/piece/pawn.rb'
require '../lib/board.rb'

describe Pawn do
  describe '#valid_moves' do
    context 'when pawn color is white' do
      subject(:pawn) { described_class.new('white') }
      let(:board) { Board.new }
        
      it 'returns valid forward moves within board boundaries' do
        position = [1, 1]
        moves = pawn.valid_moves(position, board)

        expect(moves).to include([1, 2]) # normal move
      end

      it 'does not include capture moves' do
        position = [1, 1]
        moves = pawn.valid_moves(position, board)

        expect(moves).not_to include([2, 2])
        expect(moves).not_to include([0, 2])
      end
    end

    context 'when pawn color is black' do
      let(:board) { Board.new }
      subject(:pawn) { described_class.new('black') }

      it 'returns valid forward moves within board boundaries' do
        position = [7, 7]
        moves = pawn.valid_moves(position, board)

        expect(moves).to include([7, 6]) # normal move
      end

      it 'excludes moves outside board boundaries' do
        position = [7, 7]
        moves = pawn.valid_moves(position, board)

        expect(moves).not_to include([7, 8])
      end
    end
  end

  describe '#moves' do
    context 'when pawn is white and is at [0, 0]' do
      subject(:pawn_test) { described_class.new('white') }
      let(:board) { Board.new }
      let(:available_moves) { [[1, 2], [0, 2], [2, 2]] }

      before do
        allow($stdout).to receive(:puts) # suppress output
        allow(pawn_test).to receive(:available_moves).with([0, 0], board).and_return(available_moves)
        allow(pawn_test).to receive(:player_input).and_return(1) # simulate player choosing index 1
      end

      it 'updates @current_pos based on player input' do
        pawn_test.moves([0, 0], board)
        expect(pawn_test.instance_variable_get(:@current_pos)).to eq([0, 2])
      end
    end

    context 'when pawn is black and is at [7, 7]' do
      subject(:pawn_test) { described_class.new('black') }
      let(:board) { Board.new }
      let(:available_moves) { [[7, 6], [6, 6]] }

      before do
        allow($stdout).to receive(:puts)
        allow(pawn_test).to receive(:available_moves).with([7, 7], board).and_return(available_moves)
        allow(pawn_test).to receive(:player_input).and_return(0) # simulate player choosing index 0
      end

      it 'updates @current_pos based on player input' do
        pawn_test.moves([7, 7], board)
        expect(pawn_test.instance_variable_get(:@current_pos)).to eq([7, 6])
      end
    end
  end
end