require 'sauce'

task :run do
  ENV['TEST_DIR'] ||= "test_#{Time.now.to_i}"
  puts "Test directory: #{ENV['TEST_DIR']}"
  Rake::Task["sauce:spec"].invoke
end