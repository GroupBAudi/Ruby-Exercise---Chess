require '../lib/piece/pawn.rb'
require '../lib/board.rb'

describe Pawn do
  describe '#valid_moves' do
    context 'when the color is white' do
      subject(:pawn_test) { described_class.new('white') }
      let(:board) { Board.new }
        
      it 'correctly shows three movement options when position at [1, 1]' do
        # x marks as [0, 2], [1, 2], [2, 2] 
        #   0 1 2 3 4 5 6 7 
        # 7 . . . . . . . .
        # 6 . . . . . . . .
        # 5 · · · · · · · ·
        # 4 · · · · · · · ·
        # 3 · · · · · · · ·
        # 2 x x x · · · · ·
        # 1 · ♙ · · · · · ·
        # 0 . . . . . . . .
        position = [1, 1]
        valid_moves = [[0, 2], [1, 2], [2, 2]].sort
        result = pawn_test.valid_moves(position, board).sort
        expect(result).to eq(valid_moves)
      end

      it 'correctly shows three movement options when position at [0, 5]' do
        # x marks the spot [0, 2], [1, 2], [2, 2] 
        #   0 1 2 3 4 5 6 7 
        # 7 . . . . . . . .
        # 6 x x . . . . . .
        # 5 ♙ · · · · · · ·
        # 4 · · · · · · · ·
        # 3 · · · · · · · ·
        # 2 . . . · · · · ·
        # 1 · . · · · · · ·
        # 0 . . . . . . . .
        position = [0, 5]
        valid_moves = [[0, 6], [1, 6]].sort
        result = pawn_test.valid_moves(position, board).sort
        expect(result).to eq(valid_moves)
      end
      
      # assumes [0, 0] in Pawn#initialize as haven't moved yet
      it 'correctly shows three movement options when position at [0, 5]' do
        # x marks the spot [0, 2], [1, 2], [2, 2] 
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
        valid_moves = [[0, 1], [0, 2], [1, 1]].sort
        result = pawn_test.valid_moves(position, board).sort
        expect(result).to eq(valid_moves)
      end
    end
  end
end