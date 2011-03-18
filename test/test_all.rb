
require '../lib/pngqr'
require 'qrscanner'
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
      assert_equal str, QrScanner.decode(@tempfile.path)
    ensure
      @tempfile.unlink if @tempfile
    end
  end
    
end

