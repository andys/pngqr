require 'rubygems'
require 'chunky_png'
require 'rqrcode'

class Pngqr
  class << self

    def encode(*opts)
      @filename = nil
      @scale = 1
      if Hash===opts.last
        @filename = opts.last.delete(:file) 
        @scale = opts.last.delete(:scale)
      end

      qr = RQRCode::QRCode.new(*opts)
      len = qr.module_count
      png = ChunkyPNG::Image.new(len*@scale, len*@scale, ChunkyPNG::Color::WHITE)
      
      for_each_pixel(len) do |x,y|
        if qr.modules[y][x]
          for_each_scale(x, y, @scale) do |scaled_x, scaled_y|
            png[scaled_x, scaled_y] = ChunkyPNG::Color::BLACK
          end
        end
      end
      
      if @filename
        File.open(@filename, 'wb') {|io| io << png.to_blob(:fast_rgb) }
      else
        png.to_blob(:fast_rgb)
      end
    end
  
    protected
    
    def for_each_scale(x, y, scale)
      for_each_pixel(scale) do |x_off, y_off|
        yield(x * scale + x_off, y * scale + y_off)
      end
    end
    
    def for_each_pixel(len, &bl)
      ary = (0...len).to_a
      ary.product(ary).each(&bl)
    end
    
  end
end
