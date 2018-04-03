# Require library
require "capybara"
require "selenium-webdriver"

# Add logging of javascript
Capybara.register_driver :logging_selenium_chrome_headless do |app|
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs:{browser: 'ALL'})
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, desired_capabilities: caps)
end

system("google-chrome --headless --disable-gpu https://morph.io")

# Open a Capybara session with the Selenium web driver for Chromium headless
capybara = Capybara::Session.new(:logging_selenium_chrome_headless)

p capybara.visit("https://morph.io/")

# show the javascript console
p capybara.driver.browser.manage.logs.get(:browser)

# # Open the hamburger menu
capybara.click_button "Toggle navigation"

# Search for "planningalerts"
capybara.fill_in :q, with: "planningalerts"
capybara.click_button "Submit"

# GOTCHA! You can't just search for all elements on a page. Capybara doesn't
# wait for the page to load (because what does that mean for a JS application?)
# but it's built in matchers do wait to see if the element appears. This means
# if you want to do something like `#all` you need to scope it first.
capybara.within(".search-results") do
  # Output the text of the full_name elements on the search results page
  capybara.all(".full_name").each { |e| puts e.text }
end

# Create an empty database file just so that we don't error
FileUtils.touch('data.sqlite')
