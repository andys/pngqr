require 'rubygems'
require 'chunky_png'
require 'rqrcode'


class Pngqr
  def self.encode(*opts)
    qr = RQRCode::QRCode.new(*opts)
    len = qr.module_count
    png = ChunkyPNG::Image.new(len, len, ChunkyPNG::Color::WHITE)
    (0...len).each {|row| (0...len).each {|col| png[col, row] = ChunkyPNG::Color::BLACK if qr.modules[row][col] } }
    png.to_blob(:fast_rgb)
  end
end

