require '../lib/piece/pawn.rb'
require '../lib/board.rb'

describe Pawn do
  describe '#valid_moves' do
    context 'when pawn color is white' do
      subject(:pawn_test) { described_class.new('white') }
      let(:board) { Board.new }
        
      it 'correctly shows three movement options when position at [1, 1]' do
        # x marks as [1, 2], [0, 2], [2, 2] 
        #   0 1 2 3 4 5 6 7 
        # 4 brevity brevity🥀
        # 3 · · · · · · · ·
        # 2 x x x · · · · ·
        # 1 · ♙ · · · · · ·
        # 0 . . . . . . . .
        position = [1, 1]
        valid_moves = {
          0 => [1, 2],
          1 => [0, 2],
          2 => [2, 2]
        }
        result = pawn_test.valid_moves(position, board)
        expect(result).to eq(valid_moves)
      end

      it 'correctly shows three movement options when position at [0, 5]' do
        # x marks the spot [6, 0]
        #   0 1 2 3 4 5 6 7 
        # 7 . . . . . . . .
        # 6 x x . . . . . .
        # 5 ♙ · · · · · · ·
        # 4 · · · · · · · ·
        # 1 brevity brevity 💔
        # 0 . . . . . . . .
        position = [0, 5]
        valid_moves = {
          0 => [0, 6],
          1 => [1, 6]
        }
        result = pawn_test.valid_moves(position, board)
        expect(result).to eq(valid_moves)
      end
      
      # assumes [0, 0] in Pawn#initialize as haven't moved yet
      it 'shows move forward to spaces when at beginning square' do
        # x marks the spot [0, 2], [0, 1], [1, 1] 
        #   0 1 2 3 4 5 6 7 
        # 7 . . . . . . . .
        # 6 . . . . . . . .
        # 5 . · · · · · · ·
        # 4 · · · · · · · ·
        # 3 · · · · · · · ·
        # 2 x . . · · · · ·
        # 1 x x · · · · · ·
        # 0 ♙ . . . . . . .
        position = [0, 0]
        valid_moves = {
          0 => [0, 2],
          1 => [0, 1],
          2 => [1, 1]
        }
        result = pawn_test.valid_moves(position, board)
        expect(result).to eq(valid_moves)
      end
    end

    context 'when pawn color is black' do
      let(:board) { Board.new }
      subject(:pawn_test) { described_class.new('black') }

      # Double move for black piece hasn't been implemented yet
      it 'correctly show moves with decreasing values' do
        #   0 1 2 3 4 5 6 7 
        # 7 . . . . . . . ♙
        # 6 . . . . . . . .
        # 5 . · · · · · · ·
        # 4 · · · · · · · ·
        # 3 · · · · · · · ·
        # 2 . . . · · · · ·
        # 1 . . · · · · · ·
        # 0 . . . . . . . .
        position = [7, 7]
        valid_moves = {
          0 => [7, 6],
          1 => [6, 6]
        }
        expect(pawn_test.valid_moves(position, board)).to eq(valid_moves)
      end
    end
  end

  describe '#moves' do

    context 'when pawn is white and is at [0, 0]' do
      subject(:pawn_test) { described_class.new('white') }
      let(:board) { Board.new }

      before do
        allow($stdout).to receive(:puts) # stubs puts for cleaner output
        allow(pawn_test).to receive(:available_moves) # stubs Pawn#available_moves to return true regardless
        allow(pawn_test). to receive(:player_input).with(2)
      end
      # x marks the spot [0, 2], [1, 2], [2, 2] 
        #   0 1 2 3 4 5 6 7 
        # brevity brevity
        # 3 · · · · · · · ·
        # 2 . . . · · · · ·
        # 1 x . · · · · · ·
        # 0 ♙ . . . . . . .
      it 'moves to [1, 2] correctly' do
        # as of right now the movement doesn't make sense
        # haven't implemented capture for pawn
      end
    end 
  end
end