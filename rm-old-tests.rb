#!/usr/bin/env ruby
require './lib/test_helper'

TestHelper::remove_tests Integer(ARGV[0])
