class Shape
  attr_accessor :relative_poly_coords

  POLYGONS = {
    big_triangle_down_left:  [[0, 0], [1, 0], [0, 1]],
    big_triangle_down:       [[0, 0], [1, 0], [0.5, 1]],
    big_triangle_down_right: [[0, 0], [1, 0], [1, 1]],

    triangle_down_left:      [[0, 0], [0.5, 0], [0, 0.5]],
    triangle_down:           [[0, 0], [1, 0], [0.5, 0.5]],
    triangle_down_right:     [[0, 0], [0.5, 0], [0.5, 0.5]],

    centered_square:         [[0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75]],
    square:                  [[0, 0], [0.5, 0], [0.5, 0.5], [0, 0.5]],
    rect:                    [[0, 0], [1, 0], [1, 0.5], [0, 0.5]],
    big_square:              [[0, 0], [1, 0], [1, 1], [0, 1]],

    diag_square:             [[0.5, 0], [1, 0.5], [0.5, 1], [0, 0.5]]
  }

  def initialize(shape, rotation=0)
    @relative_poly_coords = POLYGONS[shape] || []
    self.rotate(rotation)
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
    color = digest[0..5]
    center_shape_possibilities = [:big_square, :diag_square, :centered_square, nil]
    center_shape = center_shape_possibilities[digest[6..8].to_i(16) % center_shape_possibilities.length]
    middle_shape_possibilities = Shape::POLYGONS.keys
    middle_shape = middle_shape_possibilities[digest[9..11].to_i(16) % middle_shape_possibilities.length]
    middle_shape_rotation = (digest[12..14].to_i(16) % 4)
    corner_shape_possibilities = Shape::POLYGONS.except(:big_square).keys
    corner_shape = corner_shape_possibilities[digest[15..17].to_i(16) % corner_shape_possibilities.length]
    corner_shape_rotation = (digest[18..20].to_i(16) % 4)
    color_rotation = [1, -1][digest[21..24].to_i(16) % 2]

    @digest = digest
    @full_size = 255
    @chunk_size = @full_size / 3
    @png = ChunkyPNG::Canvas.new(@full_size + 1, @full_size + 1, ChunkyPNG::Color::WHITE)

    chroma = "##{color}".paint
    @corner_color = ChunkyPNG::Color.from_hex(chroma.to_s)
    @middle_color = ChunkyPNG::Color.from_hex(chroma.spin(45 * color_rotation).to_s)

    @center = Shape.new(center_shape)
    @corner = Shape.new(corner_shape, corner_shape_rotation)
    @middle = Shape.new(middle_shape, middle_shape_rotation)

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
