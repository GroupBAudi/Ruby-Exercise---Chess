# frozen_string_literal: true

# This class holds logic for creatin simulating the momvement of knight piece in BFS manner.
# BFS automatically looks for the shortest path possible
class Knight
  # Represented in x, y
  KNIGHT_MOVES = [
    [2, 1], [1, 2],
    [-2, -1], [-1, -2],
    [2, -1], [1, -2],
    [-2, 1], [-1, 2]
  ].freeze

  attr_accessor :current_pos

  def initialize(pos = [0, 0])
    @current_pos = pos
  end

  def moves(start, target)
    # moves(start, target) Your main interface.
    # It triggers everything—BFS traversal, pathfinding, and final result printout.
    path = bfs(start, target)

    puts "You made it in #{path.size} moves"
    path.each_with_index { |square, i| puts "Move #{i + 1}: #{square.inspect}" }
  end

  def valid_moves(position)
    # Returns all legal next positions from a given square,
    # using KNIGHT_MOVES and filtering out any off-board coordinates.
    x, y = position
    moves = []

    KNIGHT_MOVES.each do |dx, dy|
      new_x = x + dx
      new_y = y + dy

      moves << [new_x, new_y] if new_x.between?(0, 7) && new_y.between?(0, 7)
    end
    moves
  end

  def bfs(start, target)
    # Core search logic. Uses a queue, tracks visited positions,
    # and builds parent relationships so you can reconstruct the path.

    queue = []
    visited = []
    parents = {}

    queue << start
    until queue.empty?
      current_pos = queue.shift

      break if target == current_pos

      visited << current_pos

      valid_moves(current_pos).each do |move|
        next if visited.include?(move)

        queue << move
        visited << move
        parents[move] = current_pos
      end
    end
    build_path(parents, target)
  end

  def build_path(parents, target)
    # build_path(parents, target) Reconstructs the shortest path by
    # backtracking from target using stored parent references.
    path = []
    current = target

    while parents[current]
      path << current
      current = parents[current]
    end
    path.reverse
  end
end