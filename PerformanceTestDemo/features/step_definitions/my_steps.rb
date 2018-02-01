#encoding: UTF-8

$jmeter_log_file = 'results.jtl'
$jmeter_aggregated = 'aggregated_results.csv'
$jmeter_reporter = 'D:\apache-jmeter\lib\ext\CMDRunner.jar'
$jmeter_path = 'D:/apache-jmeter/bin'
$jmeter_reporter = ENV['reporter'] if ENV['reporter']

if ENV['jmeter-path']
  $jmeter_path = ENV['jmeter-path']
end

if ENV['jreporter']
  $jmeter_reporter = ENV['jreporter']
end

Then(/^Test name "([^"]*)" run with the following table values$/) do |jmx_file_name, table|
  # table is a table.hashes.keys # => [:users, :rampup, :loop]
  values = table.hashes.first
  $jmeter_log_file = 'load_results.jtl'
  $jmeter_aggregated = 'load_aggregated_results.csv'

  path = File.expand_path(File.join(File.dirname(__FILE__), "../performance/")) + '/'
  File.delete path + $jmeter_log_file if File.exists? path + $jmeter_log_file

  users = values[:users] if values[:users]

  jmeter_command = "jmeter -n -t #{path + jmx_file_name} -l #{path + $jmeter_log_file}"
  jmeter_command += " -Jusers=#{users}" if users
  jmeter_command += " -Jrampup=#{values[:rampup]}" if values[:rampup]
  jmeter_command += " -Jloop=#{values[:loop]}" if values[:loop]

  p jmeter_command
  p "Running Jmeter load test"
  start = Time.now
  `#{jmeter_command}`
  stop = Time.now
  p "Jmeter load test completed in #{(stop - start).to_i} seconds"

  p "Writing aggregated results into file: #{$jmeter_aggregated}"
  File.delete path + $jmeter_aggregated if File.exists? path + $jmeter_aggregated
  `java -jar #{$jmeter_reporter} --tool Reporter --generate-csv #{path + $jmeter_aggregated} --input-jtl #{path + $jmeter_log_file} --plugin-type AggregateReport`
  p "Aggregation completed"
end

When(/^The total number of Requests must be greater than "([^"]*)"$/) do |succes_rate|
  path = File.expand_path(File.join(File.dirname(__FILE__), "../performance/")) + '/'
  result_table = CSV.table(path + $jmeter_aggregated)
  last_row_that_has_totals = result_table[-1]
  result_hash = last_row_that_has_totals.to_hash
  expect(100.0 -  result_hash[:aggregate_report_error].to_f).to be > succes_rate.to_f
end

Then(/^Throughput must be greater than "([^"]*)"$/) do |throughput|
  path = File.expand_path(File.join(File.dirname(__FILE__), "../performance/")) + '/'
  result_table = CSV.table(path + $jmeter_aggregated)
  last_row_that_has_totals = result_table[-1]
  result_hash = last_row_that_has_totals.to_hash
  expect(result_hash[:aggregate_report_rate].to_f).to be > throughput.to_f
end