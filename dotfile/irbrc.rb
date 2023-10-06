#!/usr/bin/env ruby

# Readline
require 'irb/completion'
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

# Keep history
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-history"
IRB.conf[:USE_MULTILINE] = false
