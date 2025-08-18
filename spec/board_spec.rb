require '../lib/board.rb'

describe Board do
  subject(:board) { described_class.new }
  # incoming query message
  # asserts result of calling board.grid
  
  it 'creates 8x8 grid' do
    board_size = board.grid.all? { |row| row.length == 8 }
    expect(board_size).to eq(true)
  end
end