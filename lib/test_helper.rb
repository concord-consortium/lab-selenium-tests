require 'RMagick'
require 'json'

class TestHelper
  @@main_dir = 'screenshots'
  @@tests_metadata = "#{@@main_dir}/metadata.js"
  @@expected_screenshots_dir = "#{@@main_dir}/expected_screenshots"
  TESTS_METADATA_NAME = 'TESTS_METADATA'
  IMAGES_METADATA_NAME = 'IMAGES_METADATA'

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

    if browser == :iPad || browser == :Android
      img = Magick::Image.read(screenshot_path).first
      # For some reason both iPad and Android sreenshots are rotated. -- 3/24/2017 This does not seem the case anymore
      # img.rotate!(-90)
      # Both iPad and Android screenshots contain top bar with clock, URL etc.
      # that could obfuscate the image comparison algorithm results.
      top_margin = browser == :iPad ? 63 : 10
      img.crop!(0, top_margin, img.columns, img.rows - top_margin)
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
      array = parse_array(f)
      tests_to_remove = array[0...count]
      array = array.drop(count)
      write_array(f, array, TESTS_METADATA_NAME)
    end
    tests_to_remove.each do |test|
      path = "#{@@main_dir}/#{test['testName']}"
      puts "Removing #{path}..."
      `rm -rf #{path}`
    end
  end

  def self.limit_test_count(max_count)
    test_count = 0
    open_and_lock_file "#{@@tests_metadata}" do |f|
      array = parse_array(f)
      test_count = array.length
    end
    if test_count > max_count
      remove_tests(test_count - max_count)
    end
  end

  def self.parse_array(file)
    content = file.read
    content && content.lines[1..-2] ? JSON.parse(content.lines[1..-2].join) : []
  end

  def self.write_array(file, array, array_name)
    file.rewind
    file.puts("var #{array_name} =")
    file.puts(JSON.pretty_generate(array))
    file.puts(';')
    file.flush
    file.truncate(file.pos)
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
      array = TestHelper.parse_array(f)
      # Find old metadata, replace with new one and save file.
      index = array.index { |m| m['testName'] == @test_name }
      if index
        array[index] = new_test_metadata
      else
        array << new_test_metadata
      end
      TestHelper.write_array(f, array, TESTS_METADATA_NAME)
    end
  end

  def add_js_image_metadata(new_image)
    TestHelper.open_and_lock_file "#{@test_dir}/images_metadata.js" do |f|
      array = TestHelper.parse_array(f)
      array.push(new_image)
      TestHelper.write_array(f, array, IMAGES_METADATA_NAME)
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
