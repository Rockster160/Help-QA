class Shape
  attr_accessor :relative_poly_coords

  POLYGONS = {
    big_triangle_down_left:  [[  0,   0], [  1,   0], [  0,   1]],
    big_triangle_down:       [[  0,   0], [  1,   0], [0.5,   1]],
    big_triangle_down_right: [[  0,   0], [  1,   0], [  1,   1]],

    triangle_down_left:      [[  0,   0], [0.5,   0], [  0, 0.5]],
    triangle_down:           [[  0,   0], [  1,   0], [0.5, 0.5]],
    triangle_down_right:     [[  0,   0], [0.5,   0], [0.5, 0.5]],

    centered_square:         [[0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75]],
    square:                  [[  0,   0], [0.5,   0], [0.5, 0.5], [0, 0.5]],
    rect:                    [[  0,   0], [  1,   0], [  1, 0.5], [0, 0.5]],
    big_square:              [[  0,   0], [  1,   0], [  1,   1], [0,   1]],

    diag_square:             [[0.5,   0], [  1, 0.5], [0.5,   1], [0, 0.5]]
  }
  # 11 shapes

  # Circle, too?
  # Center shapes?

  def initialize(*allowed_shapes)
    allowed_shapes = POLYGONS.keys if allowed_shapes.empty?
    @relative_poly_coords = []
    shape = allowed_shapes.try(:sample)
    return unless shape
    @relative_poly_coords = POLYGONS[shape]
    self.rotate(rand(4))
  end

  def rotate(turns=0)
    turns.times do |t|
      self.relative_poly_coords = relative_poly_coords.map do |old_x, old_y|
        [(-(old_y - 0.5)) + 0.5, ((old_x - 0.5)) + 0.5]
      end
    end
    self
  end

end

class IdenticonGenerator
  attr_reader :src

  def self.generate(str)
    identicon = new(Digest::MD5.hexdigest(str.to_s))
    identicon.src
  end

  def initialize(digest)
    # "2eeecd72c567401e6988624b179d0b14"
    @digest = digest
    @full_size = 255
    @chunk_size = @full_size / 3
    @png = ChunkyPNG::Canvas.new(@full_size + 1, @full_size + 1, ChunkyPNG::Color::WHITE)
    # Parse the digest, determine the stuffs
    color_string = "##{'0123456789ABCDEF'.split('').sample(6).join('')}"

    chroma = color_string.paint
    @corner_color = ChunkyPNG::Color.from_hex(chroma.to_s)
    @middle_color = ChunkyPNG::Color.from_hex([chroma.spin(45).to_s, chroma.spin(-45).to_s].sample)

    @center = Shape.new(:big_square, :diag_square, :centered_square, nil)
    @corner = Shape.new
    @middle = Shape.new

    draw_at(1, 1, @center)

    draw_at(0, 0, @corner.rotate(0))
    draw_at(2, 0, @corner.rotate(1))
    draw_at(0, 2, @corner.rotate(2))
    draw_at(2, 2, @corner.rotate(3))

    draw_at(1, 0, @middle.rotate(0))
    draw_at(2, 1, @middle.rotate(1))
    draw_at(0, 1, @middle.rotate(2))
    draw_at(1, 2, @middle.rotate(3))

    @src = @png.to_data_url
  end

  private

  def draw_at(x, y, shape)
    return if shape.relative_poly_coords.none?
    ox, oy = (x * @chunk_size), (y * @chunk_size)
    if (x == 1 || y == 1) && !(x == 1 && y == 1)
      color = @middle_color
    elsif
      color = @corner_color
    end
    @png.polygon(shape.relative_poly_coords.map { |rel_x, rel_y| [(rel_x * @chunk_size) + ox, (rel_y * @chunk_size) + oy] }, color, color)
  end

end

module Identicon
  def self.generate(str)
    IdenticonGenerator.generate(str)
  end
end
