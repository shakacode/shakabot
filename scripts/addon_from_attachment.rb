#!/usr/bin/env ruby

require 'json'

config = JSON.parse($stdin.read)

config.each do |addon|
  addon['attachments'].each do |attachment|
    puts addon['name'] if attachment['name'] == ARGV[0]
  end
end
