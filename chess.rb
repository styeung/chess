# encoding: utf-8
require 'colorize'
require 'debugger'

class Piece
  attr_accessor :pos, :board, :color

  def initialize(pos,board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def valid_moves
    valid_moves = []
    self.moves.each do |move|
      valid_moves << move unless move_into_check?(move)
    end

    valid_moves
  end

  def move_into_check?(end_pos)
    new_board = @board.deep_dup
    new_board.move!(self.pos, end_pos)

    new_board.in_check(self.color)
  end
end

class SlidingPiece < Piece
  attr_accessor :pos, :board, :color

  def initialize(pos,board, color)
    super
  end

  def moves
    valid_coords = []
    #debugger
    self.deltas.each do |delta|
      coords = @pos.dup

      while (0...8).to_a.include?(coords[0]+delta[0]) && (0...8).to_a.include?(coords[1]+delta[1])
        coords = coords.dup
        coords[0] += delta[0]
        coords[1] += delta[1]

        if self.board.contains_friendly_piece?(@pos, coords)
          break
        elsif self.board.contains_enemy_piece?(@pos, coords)
          valid_coords << coords
          break
        else
          valid_coords << coords
        end
      end
    end

    valid_coords
  end

end

class SteppingPiece < Piece
  attr_accessor :pos, :board, :color, :deltas

  def initialize(pos,board, color)
    super
  end

  def moves
    valid_coords = []

    self.deltas.each do |delta|
      coords = @pos.dup
      coords[0] += delta[0]
      coords[1] += delta[1]

      if (0...8).to_a.include?(coords[0]) && (0...8).to_a.include?(coords[1])
        if self.board.contains_friendly_piece?(@pos, coords)
          next
        elsif self.board.contains_enemy_piece?(@pos, coords)
          valid_coords << coords
          next
        else
          valid_coords << coords
        end
      end
    end

    valid_coords
  end
end

class King < SteppingPiece
  attr_accessor :pos, :board, :color, :deltas

  def initialize(pos, board, color)
    super

    @deltas = [
      [1, 0],
      [0, 1],
      [-1, 0],
      [0, -1],
      [1, -1],
      [1, 1],
      [-1, -1],
      [-1, 1]
    ]
  end
end

class Knight < SteppingPiece
  attr_accessor :pos, :board, :color, :deltas

  def initialize(pos, board, color)
    super

    @deltas = [
      [2, 1],
      [1, 2],
      [-2, 1],
      [1, -2],
      [-2, -1],
      [-1, -2],
      [-1, 2],
      [2, -1]
    ]
  end
end

class Queen < SlidingPiece
  attr_accessor :pos, :board, :color, :deltas

  def initialize(pos, board, color)
    super

    @deltas = [
      [1, 0],
      [0, 1],
      [-1, 0],
      [0, -1],
      [1, -1],
      [1, 1],
      [-1, -1],
      [-1, 1]
    ]
  end
end

class Bishop < SlidingPiece
  attr_accessor :pos, :board, :color, :deltas

  def initialize(pos, board, color)
    super

    @deltas = [
      [1, -1],
      [1, 1],
      [-1, -1],
      [-1, 1]
    ]
  end
end

class Rook < SlidingPiece
  attr_accessor :pos, :board, :color, :deltas

  def initialize(pos, board, color)
    super

    @deltas = [
      [1, 0],
      [0, 1],
      [-1, 0],
      [0, -1]
    ]
  end
end

class Pawn < SteppingPiece
  attr_accessor :pos, :board, :color

  def initialize(pos, board, color)
    super
  end

  def deltas
    possible_deltas = []
    if self.color == "black"
      possible_deltas << [1,0]
      if self.board.contains_enemy_piece?(@pos, [pos[0] + 1,pos[1] + 1])
        possible_deltas << [1,1]
      end
      if self.board.contains_enemy_piece?(@pos, [pos[0] + 1,pos[1] - 1])
        possible_deltas << [1,-1]
      end
    elsif self.color == "white"
      possible_deltas << [-1,0]
      if self.board.contains_enemy_piece?(@pos, [pos[0] - 1,pos[1] - 1])
        possible_deltas << [-1,-1]
      end
      if self.board.contains_enemy_piece?(@pos, [pos[0] - 1,pos[1] + 1])
        possible_deltas << [-1,1]
      end
    end
    possible_deltas
  end

end

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) {Array.new(8)}
  end

  def board_fill
    (0...8).each do |row|
      (0...8).each do |column|
        pos = [row,column]

        if pos == [0,0] || pos == [0,7]
          self[pos] = Rook.new(pos,self,"black")
        elsif pos == [7,0] || pos == [7,7]
          self[pos] = Rook.new(pos,self,"white")
        elsif pos == [0,1] || pos == [0,6]
          self[pos] = Knight.new(pos,self,"black")
        elsif pos == [7,1] || pos == [7,6]
          self[pos] = Knight.new(pos,self,"white")
        elsif pos == [0,2] || pos == [0,5]
          self[pos] = Bishop.new(pos,self,"black")
        elsif pos == [7,2] || pos == [7,5]
          self[pos] = Bishop.new(pos,self,"white")
        elsif pos == [0,3]
          self[pos] = Queen.new(pos,self,"black")
        elsif pos == [7,3]
          self[pos] = Queen.new(pos,self,"white")
        elsif pos == [0,4]
          self[pos] = King.new(pos,self,"black")
        elsif pos == [7,4]
          self[pos] = King.new(pos,self,"white")
        elsif pos[0] == 1
          self[pos] = Pawn.new(pos,self,"black")
        elsif pos[0] == 6
          self[pos] = Pawn.new(pos,self,"white")
        end
      end
    end
  end

  def [](pos)
    self.grid[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    self.grid[pos[0]][pos[1]] = piece
  end

  def contains_enemy_piece?(self_coord, target_coord)
    unless self[self_coord].nil? || self[target_coord].nil?
      return self[self_coord].color != self[target_coord].color
    end
    false
  end

  def contains_friendly_piece?(self_coord, target_coord)
    if self[self_coord] && self[target_coord]
      return self[self_coord].color == self[target_coord].color
    end
    false
  end

  def in_check(color)
    king_location = nil
    (0...8).each do |row|
      (0...8).each do |column|
        pos = [row,column]
        unless self[pos].nil?
          if self[pos].class == King && self[pos].color == color
            king_location = pos
          end
        end
      end
    end

    (0...8).each do |row|
      (0...8).each do |column|
        pos = [row,column]
        unless self[pos].nil?
          if self[pos].color != color
            if self[pos].moves.include?(king_location)
              return true
            end
          end
        end
      end
    end

    return false
  end

  def checkmate?(color)
    if self.in_check(color)
      self.grid.each do |row|
        row.each do |space|
          unless space.nil?
            return false if space.color == color && !space.valid_moves.empty?
          end
        end
      end
      return true
    end

    false
  end

  def move(start, end_pos)

    raise RuntimeError.new("You have no piece there") if self[start].nil?
    raise RuntimeError.new("You cannot move there") if !self[start].moves.include?(end_pos)
    raise RuntimeError.new("This puts you in check") if self[start].move_into_check?(end_pos)

    self[end_pos] = self[start].class.new(start, self.dup, self[start].color)
    self[start] = nil
    self[end_pos].pos = end_pos.dup
  end

  def move!(start, end_pos)
    raise RuntimeError.new("You have no piece there") if self[start].nil?
    raise RuntimeError.new("You cannot move there") if !self[start].moves.include?(end_pos)

    self[end_pos] = self[start].class.new(start, self.dup, self[start].color)
    self[start] = nil
    self[end_pos].pos = end_pos.dup
  end

  def deep_dup
    new_board = Board.new

    (0...8).each do |row|
      (0...8).each do |column|
        pos = [row, column]
        if self[pos].nil?
          next
        elsif self[pos].class == Pawn
          new_board[pos] = Pawn.new(pos, new_board, self[pos].color)
        elsif self[pos].class == King
          new_board[pos] = King.new(pos, new_board, self[pos].color)
        elsif self[pos].class == Queen
          new_board[pos] = Queen.new(pos, new_board, self[pos].color)
        elsif self[pos].class == Rook
          new_board[pos] = Rook.new(pos, new_board, self[pos].color)
        elsif self[pos].class == Knight
          new_board[pos] = Knight.new(pos, new_board, self[pos].color)
        elsif self[pos].class == Bishop
          new_board[pos] = Bishop.new(pos, new_board, self[pos].color)
        end
      end
    end

    new_board
  end

  def render
    (0...8).each do |row|
      (0...8).each do |column|
        if !self[[row,column]].nil?
          if row % 2 == column % 2
            case [self[[row,column]].class, self[[row,column]].color]
            when [King, "black"]
              print "♚"
            when [King, "white"]
              print "♔"
            when [Queen, "black"]
              print "♛"
            when [Queen, "white"]
              print "♕"
            when [Rook, "black"]
              print "♜"
            when [Rook, "white"]
              print "♖"
            when [Bishop, "black"]
              print "♝"
            when [Bishop, "white"]
              print "♗"
            when [Knight, "black"]
              print "♞"
            when [Knight, "white"]
              print "♘"
            when [Pawn, "black"]
              print "♟"
            when [Pawn, "white"]
              print "♙"
            end
          else
            case [self[[row,column]].class, self[[row,column]].color]
            when [King, "black"]
              print "♚".colorize(:background => :light_black)
            when [King, "white"]
              print "♔".colorize(:background => :light_black)
            when [Queen, "black"]
              print "♛".colorize(:background => :light_black)
            when [Queen, "white"]
              print "♕".colorize(:background => :light_black)
            when [Rook, "black"]
              print "♜".colorize(:background => :light_black)
            when [Rook, "white"]
              print "♖".colorize(:background => :light_black)
            when [Bishop, "black"]
              print "♝".colorize(:background => :light_black)
            when [Bishop, "white"]
              print "♗".colorize(:background => :light_black)
            when [Knight, "black"]
              print "♞".colorize(:background => :light_black)
            when [Knight, "white"]
              print "♘".colorize(:background => :light_black)
            when [Pawn, "black"]
              print "♟".colorize(:background => :light_black)
            when [Pawn, "white"]
              print "♙".colorize(:background => :light_black)
            end
          end
        else
          if row % 2 != column % 2
            print " ".colorize(:background => :light_black)
          else
            print " "
          end
        end
      end
      puts
    end
  end
end

class Game
  def initialize
    @board = Board.new
    @board.board_fill
    self.play
  end

  def play
    turn = 1
    turn_color = "white"

    until @board.checkmate?(turn_color)
      @board.render

      if turn % 2 == 0
        turn_color = "black"
      else
        turn_color = "white"
      end

      puts "#{turn_color.capitalize} turn"
      puts "Enter the coordinates of the piece you would like to move:"
      start_pos = gets.chomp.split(",").map { |num| num.to_i }

      if @board[start_pos].color != turn_color
        puts "That is not your piece!"
        next
      end

      puts "Enter the coordinates of the space you would like to move to:"
      end_pos = gets.chomp.split(",").map { |num| num.to_i }

      begin
        @board.move(start_pos, end_pos)
      rescue RuntimeError => e
        p @board.checkmate?(turn_color)
        puts e.message
        next
      end

      turn += 1
      #debugger

    end
  end
end

Game.new