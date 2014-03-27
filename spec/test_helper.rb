require 'RMagick'

class TestHelper
  @@main_dir = 'screenshots'
  @@expected_screenshots_dir = "#{@@main_dir}/expected_screenshots"

  def initialize
    @test_dir = "#{@@main_dir}/test_#{Time.now.to_i}"
    @images_metadata = []
    # Prepare screenshots/test_<timestamp> folder.
    `mkdir -p #{@test_dir}`
    `cp #{@@main_dir}/results_template.html #{@test_dir}/index.html`
  end

  def save_screenshot(page, filename, interactive_url)
    screenshot_path = "#{@test_dir}/#{filename}"
    page.save_screenshot(screenshot_path)

    @images_metadata << {
      :filename => filename,
      :diff     => compare_images(screenshot_path, screenshot_path.gsub(@test_dir, @@expected_screenshots_dir)),
      :interactiveUrl => interactive_url
    }
    generate_js_image_metadata
  end

  private 

  def generate_js_image_metadata
    f = File.new "#{@test_dir}/images_metadata.js", 'w'
    f.write 'var IMAGES_METADATA = '
    f.write JSON.pretty_generate(@images_metadata)
    f.puts  ';'
    f.close
  end

  def compare_images(path_a, path_b) 
    return nil if !File.exist?(path_a) or !File.exist?(path_b)
    a = Magick::Image::read(path_a).first  
    b = Magick::Image::read(path_b).first 
    a.compare_channel(b, Magick::RootMeanSquaredErrorMetric)[1] * 100
  end
end
