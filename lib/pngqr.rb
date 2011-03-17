require 'rubygems'
require 'chunky_png'
require 'rqrcode'

class Pngqr
  class << self

    def encode(*opts)
      opthash = {}
      if Hash===opts.last
        opthash = opts.pop
        @filename = opthash.delete(:file) 
        @scale = opthash.delete(:scale)
        @border = opthash.delete(:border)
      end
      @scale ||= 1
      @border ||= 0

      qr = nil
      if(opthash[:size]) # user supplied size
        qr = RQRCode::QRCode.new(*opts, opthash)
      else
        # autosize algorithm: start at size=1 and increment until it worked
        opthash[:size] = 1
        while qr.nil?
          qr = begin
            RQRCode::QRCode.new(*opts, opthash)
          rescue RQRCode::QRCodeRunTimeError => e
            opthash[:size] += 1
            raise unless e.to_s =~ /overflow/ && opthash[:size] <= 40
          end
        end
      end
      len = qr.module_count
      png = ChunkyPNG::Image.new(len*@scale + 2*@border, len*@scale + 2*@border, ChunkyPNG::Color::WHITE)
      
      for_each_pixel(len) do |x,y|
        if qr.modules[y][x]
          for_each_scale(x, y, @scale) do |scaled_x, scaled_y|
            png[scaled_x + @border, scaled_y + @border] = ChunkyPNG::Color::BLACK
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
