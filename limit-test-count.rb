#!/usr/bin/env ruby
require './lib/test_helper'

TestHelper.limit_test_count Integer(ARGV[0])
