#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

Rails.logger = @logger = Logger.new STDOUT


$running = true
Signal.trap("TERM") do
  $running = false
end

workers = []
Currency.all.each do |currency|
  workers << Worker::FundStats.new(currency)
end
Market.all.each do |market|
  workers << Worker::TradeStats.new(market)
end

while($running) do
  workers.each do |worker|
    worker.run
  end

  sleep 5
end