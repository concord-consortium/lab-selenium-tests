require 'RMagick'
require 'json'

class TestHelper
  @@main_dir = 'screenshots'
  @@tests_metadata = "#{@@main_dir}/metadata.js"
  @@expected_screenshots_dir = "#{@@main_dir}/expected_screenshots"

  def initialize(test_name, interactives_count)
    @test_name = "test_#{test_name || Time.now.to_i}"
    @test_dir = "#{@@main_dir}/#{@test_name}"
    @interactives_count = interactives_count
    @tested_interactives_count = 0
    @test_date = Time.now
    @images_diff = []
    # Prepare screenshots/test_<timestamp> folder.
    `mkdir -p #{@test_dir}`
    `cp #{@@main_dir}/results_template.html #{@test_dir}/index.html`
    update_tests_metadata
  end

  def save_screenshot(driver, filename, interactive_url, browser)
    screenshot_path = "#{@test_dir}/#{filename}"
    driver.save_screenshot screenshot_path

    if browser == :iPad
      img = Magick::Image.read(screenshot_path).first
      # iPad screenshots are rotated...
      img.rotate!(-90)
      # They also contain top bar with clock, URL etc. We don't need it,
      # it would only obfuscate the image comparison algorithm results.
      img.crop!(0, 190, img.columns, img.rows - 190)
      img.write(screenshot_path)
    end

    new_image = {
      filename: filename,
      diff: compare_images(screenshot_path, screenshot_path.gsub(@test_dir, @@expected_screenshots_dir)),
      interactiveUrl: interactive_url
    }
    @images_diff << new_image[:diff]
    add_js_image_metadata(new_image)
    update_tests_metadata
  end

  def interactive_test_completed
    @tested_interactives_count += 1
    update_tests_metadata
  end

  def self.remove_tests(count)
    tests_to_remove = nil
    open_and_lock_file "#{@@tests_metadata}" do |f|
      content = f.read
      array = content && content.lines[1..-2] ? JSON.parse(content.lines[1..-2].join) : []
      tests_to_remove = array[0...count]
      array = array.drop(count)
      f.rewind
      f.puts('var TESTS_METADATA =')
      f.puts(JSON.pretty_generate(array))
      f.puts(';')
      f.flush
      f.truncate(f.pos)
    end
    tests_to_remove.each do |test|
      path = "#{@@main_dir}/#{test['testName']}"
      puts "Removing #{path}..."
      `rm -rf #{path}`
    end
  end

  def self.open_and_lock_file(file)
    File.open(file, File::RDWR | File::CREAT, 0644) do |f|
      begin
        f.flock(File::LOCK_EX)
        yield f
      ensure
        f.flock(File::LOCK_UN)
      end
    end
  end

  private

  def update_tests_metadata
    new_test_metadata = {
      testName: @test_name,
      date: @test_date,
      interactivesCount: @interactives_count,
      testedInteractivesCount: @tested_interactives_count,
      rootMeanSquaredError: root_mean_squared_error(@images_diff)
    }

    TestHelper.open_and_lock_file "#{@@tests_metadata}" do |f|
      content = f.read
      array = content && content.lines[1..-2] ? JSON.parse(content.lines[1..-2].join) : []
      # Find old metadata, replace with new one and save file.
      index = array.index { |m| m['testName'] == @test_name }
      if index
        array[index] = new_test_metadata
      else
        array << new_test_metadata
      end
      f.rewind
      f.puts('var TESTS_METADATA =')
      f.puts(JSON.pretty_generate(array))
      f.puts(';')
      f.flush
      f.truncate(f.pos)
    end
  end

  def add_js_image_metadata(new_image)
    TestHelper.open_and_lock_file "#{@test_dir}/images_metadata.js" do |f|
      content = f.read
      array = content && content.lines[1..-2] ? JSON.parse(content.lines[1..-2].join) : []
      array.push(new_image)
      f.rewind
      f.puts('var IMAGES_METADATA =')
      f.puts(JSON.pretty_generate(array))
      f.puts(';')
      f.flush
      f.truncate(f.pos)
    end
  end

  def compare_images(path_a, path_b)
    return 100 if !File.exist?(path_a) || !File.exist?(path_b)
    a = Magick::Image.read(path_a).first
    b = Magick::Image.read(path_b).first
    a.resize!(b.columns, b.rows) if a.columns != b.columns || a.rows != b.rows
    a.compare_channel(b, Magick::RootMeanSquaredErrorMetric)[1] * 100
  end

  def root_mean_squared_error(array)
    return 0 if array.length == 0
    sq_sum = array.reduce { |a, e| a + e * e }
    Math.sqrt(sq_sum / array.length)
  end
end
