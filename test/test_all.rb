require File.expand_path(File.join(File.dirname(__FILE__), '../lib/pngqr'))
begin
  require 'qrscanner'
rescue LoadError
  begin
    require 'zxing'
  rescue LoadError
  end
end
require 'test/unit'
require 'tempfile'

class TestPngqr < Test::Unit::TestCase
  def test_autosize
    (0..3).each do |n|
      assert_encoded_equals_decoded('x'*(10**n))
    end
  end

  def test_static_size
    assert_encoded_equals_decoded('y'*10, :size => 2)
    assert_encoded_equals_decoded('y'*100, :size => 20)
    assert_encoded_equals_decoded('y'*1000, :size => 40)
  end

  def test_scale
    assert_encoded_equals_decoded('hello, world', :scale => 5)
  end

  def test_border
    assert_encoded_equals_decoded('hello, world', :border => 5)
  end


  protected
  def assert_encoded_equals_decoded(*opts)
    begin
      str = opts.first
      @tempfile = Tempfile.new(self.class.to_s)
      @tempfile.write(Pngqr.encode(*opts))
      @tempfile.close
      if Object.const_defined? :QrScanner
        assert_equal str, QrScanner.decode(@tempfile.path)
      elsif Object.const_defined? :ZXing
        assert_equal str, ZXing.decode(@tempfile)
      else
        raise Exception, "QR Decoder required. Please gem install qrscanner or zxing."
      end
    ensure
      @tempfile.unlink if @tempfile
    end
  end

end

