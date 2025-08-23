require '../lib/piece/pawn.rb'
require '../lib/board.rb'

describe Pawn do
  describe '#valid_moves' do
    context 'when pawn color is white' do
      let(:board) { Board.new }
      let(:position) { position = [6, 1] } # second bottom row
      subject(:pawn) { described_class.new(:white, position) }
        
      it 'returns valid forward moves within board boundaries' do
        moves = pawn.valid_moves(position, board)
        
        expect(moves).to include([6, 2]) # normal move
        expect(moves).to include([6, 3]) # special move
      end

      it 'does not include capture moves' do
        moves = pawn.valid_moves(position, board)

        expect(moves).not_to include([5, 1])
        expect(moves).not_to include([5, 3])
      end
    end

    context 'when pawn color is black' do
      let(:board) { Board.new }
      let(:position) { position = [1, 1] } # second top row
      subject(:pawn) { described_class.new(:black, position) }

      it 'returns valid forward moves within board boundaries' do
        moves = pawn.valid_moves(position, board)
        
        expect(moves).to include([1, 2]) # normal move
        expect(moves).to include([1, 3]) # special move
      end

      it 'does not include capture moves' do
        moves = pawn.valid_moves(position, board)

        expect(moves).not_to include([0, 2])
        expect(moves).not_to include([2, 3])
      end
    end
  end

  describe '#valid_capture_moves' do
    context 'when pawn is white, at [4, 3]' do
      let(:board) { Board.new }
      let(:position_white) { [4, 3] }
      subject(:pawn_white) { described_class.new(:white, position_white) }
      

      before do
        board.grid[4][3] = pawn_white
      end
      
      it 'shows additional move that signals capture when opposing pawn at [5, 4]' do
        position_black = [5, 4] 
        pawn_black = Pawn.new(:black, position_black)
        board.grid[5][4] = pawn_black
        moves = pawn_white.valid_capture_moves(position_white, board)

        expect(moves).to include([5, 4])
      end

      it 'shows no capture moves when no pieces relative to pawn diagonally' do
        moves = pawn_white.valid_capture_moves(position_white, board)

        expect(moves).to eq([])
      end
    end
    
    context 'when pawn is black, at [5, 4] and opposing pawn at [4, 5]' do
      let(:board) { Board.new }
      let(:position_black) { [5, 4] }
      subject(:pawn_black) { described_class.new(:black, position_black) }
      
      before do
        board.grid[5][4] = pawn_black
      end
      
      it 'shows additional move that signals capture when opposing pawn at [4, 5]' do
        position_white = [4, 5] 
        pawn_white = Pawn.new(:white, position_white)
        board.grid[4][5] = pawn_white
        moves = pawn_black.valid_capture_moves(position_black, board)

        expect(moves).to include([4, 5])
      end

      it 'shows no capture moves when no pieces relative to pawn diagonally' do
        moves = pawn_black.valid_capture_moves(position_black, board)

        expect(moves).to eq([])
      end
    end
  end

  describe '#moves' do
    context 'when pawn is white and is at [6, 1]' do
      let(:board) { Board.new }
      let(:position) { position = [6, 1] } # second bottom row
      subject(:pawn_test) { described_class.new(:white, position) }
      let(:available_moves) { [[6, 3], [6, 2]] }

      before do
        allow($stdout).to receive(:puts) # suppress output
        allow(pawn_test).to receive(:available_moves).with(position, board).and_return(available_moves)
        allow(pawn_test).to receive(:player_input).and_return(1) # simulate player choosing index 1
      end

      it 'updates @current_pos based on player input' do
        pawn_test.moves(position, board)
        expect(pawn_test.instance_variable_get(:@current_pos)).to eq([6, 2])
      end
    end

    context 'when pawn is black and is at [1, 1]' do
      let(:board) { Board.new }
      let(:position) { position = [1, 1] } # second bottom row
      subject(:pawn_test) { described_class.new(:black, position) }
      let(:available_moves) { [[1, 3], [1, 2]] }

      before do
        allow($stdout).to receive(:puts) # suppress output
        allow(pawn_test).to receive(:available_moves).with(position, board).and_return(available_moves)
        allow(pawn_test).to receive(:player_input).and_return(0) # simulate player choosing index 0
      end

      it 'updates @current_pos based on player input' do
        pawn_test.moves(position, board)
        expect(pawn_test.instance_variable_get(:@current_pos)).to eq([1, 3])
      end
    end
  end
end