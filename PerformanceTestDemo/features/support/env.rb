#encoding: UTF-8

require 'cucumber'
require 'rspec'
require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium
Capybara.default_selector = :css
Capybara.default_max_wait_time = 5
Capybara.ignore_hidden_elements = false
Capybara.exact = true
World(Capybara::DSL)

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome,
                                      :switches => %w[--disable-extensions --disable-web-security --start-maximized])
end
