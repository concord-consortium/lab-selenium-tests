require 'RMagick'

class TestHelper
  @@main_dir = 'screenshots'
  @@expected_screenshots_dir = "#{@@main_dir}/expected_screenshots"

  def initialize
    @test_dir = "#{@@main_dir}/#{ENV['TEST_DIR']}"
    @images_metadata = []
    # Prepare screenshots/test_<timestamp> folder.
    `mkdir -p #{@test_dir}`
    `cp #{@@main_dir}/results_template.html #{@test_dir}/index.html`
  end

  def save_screenshot(selenium, filename, interactive_url)
    screenshot_path = "#{@test_dir}/#{filename}"
    selenium.save_screenshot(screenshot_path)

    new_image = {
      :filename => filename,
      :diff     => compare_images(screenshot_path, screenshot_path.gsub(@test_dir, @@expected_screenshots_dir)),
      :interactiveUrl => interactive_url
    }
    add_js_image_metadata new_image
  end

  private 

  def add_js_image_metadata new_image
    File.open("#{@test_dir}/images_metadata.js", File::RDWR|File::CREAT, 0644) do |f|
      begin
        f.flock File::LOCK_EX
        content = f.read
        array = content && content.lines[1..-2] ? JSON.parse(content.lines[1..-2].join) : []
        array.push new_image
        f.rewind
        f.puts 'var IMAGES_METADATA ='
        f.puts JSON.pretty_generate(array)
        f.puts ';'
        f.flush
        f.truncate f.pos
      ensure
        f.flock File::LOCK_UN
      end
    end
  end

  def compare_images(path_a, path_b) 
    return nil if !File.exist?(path_a) or !File.exist?(path_b)
    a = Magick::Image::read(path_a).first  
    b = Magick::Image::read(path_b).first 
    a.compare_channel(b, Magick::RootMeanSquaredErrorMetric)[1] * 100
  end
end
