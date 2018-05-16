require 'report_builder'

caps0 = @caps_ipad
caps1 = @caps_ipad_sim
# caps3 = @caps_android_emulator


# Before('@Local_Test') do
# 	@driver = Appium::Driver.new(caps0, true)
# 	Appium.promote_appium_methods Object
# 	@driver.start_driver
# end

# Before('@Android_Test') do
# 	@driver = Appium::Driver.new(caps1, true)
# 	Appium.promote_appium_methods Object
# 	@driver.start_driver
# end


Before('@restart') do
	@driver = Appium::Driver.new(caps1, true)
	Appium.promote_appium_methods Object
	@driver.start_driver
end

# Before('@skip') do 
#   skip_this_scenario
# end

After do |s|
  # Tell Cucumber to quit after this scenario is done - if it failed.
  if s.failed?
    screenshot('/Users/shellyhan/Desktop/1-range-try-cucmber/features/results')
    # encoded_img = @driver.screenshot(:base64)
    # embed("data:image/png;base64,#{encoded_img}",'image/png')
  end
end


at_exit do
  @driver.driver_quit
  Cucumber.wants_to_quit = true
  ReportBuilder.configure do |config|
    config.json_path = '/Users/shellyhan/Desktop/1-range-try-cucmber/features/results'
    config.report_path = '/Users/shellyhan/Desktop/1-range-try-cucmber/features/results'
    config.report_title = 'My Test Results'
    config.include_images = 'true'
    config.additional_info = {Browser: 'browser', Environment: 'environment', MoreInfo: 'more info'}
  end
  ReportBuilder.build_report
end