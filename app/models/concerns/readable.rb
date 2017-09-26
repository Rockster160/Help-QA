# has attribute - read_at:datetime
module Readable
  extend ActiveSupport::Concern

  included do
    scope :read, -> { where.not(read_at: nil) }
    scope :unread, -> { where(read_at: nil) }
    scope :order_by_read, -> { order(read_at: :desc) }
  end

  def read?; read_at?; end
  def unread?; !read_at?; end

  def read(time=DateTime.current)
    update(read_at: time)
  end

end
