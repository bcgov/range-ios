require "yaml"
#require "rspec"
#require "sauce_whisk"
require "appium_lib"

# configure for local simulator:
def caps_ipad_sim
  { caps: {
      deviceName: "iPad Pro",
      platformName: "iOS",
      appPackage: "ca.bc.gov.pathfinder.mobile.MyRA",
      newCommandTimeout: "3600",
      automationName: "XCUITest",
      bundleId: "ca.bc.gov.pathfinder.mobile.MyRA",
      xcodeOrgId: "TCH45SXZ69",
      xcodeSigningId: "iPhone Developer",
      udid: "2617CB2C-16A0-40B5-A06E-C2F651C2F942",
      platformVersion: "11.3",
      # orientation: "LANDSCAPE",
      setWebContentsDebuggingEnabled: "true"
      # noReset: "false",
      # fullReset: "false",
      # showIOSLog: "true",
      # autoAcceptAlerts: "true",
      # showXcodeLog: "true",
      # useNewWDA: "true"
      # resetOnSessionStartOnly: "true"
    }
  }
end


# configure for real device:
def caps_ipad
  { caps: {
      deviceName: "BC’s iPad",
      platformName: "iOS",
      appPackage: "ca.bc.gov.pathfinder.mobile.MyRA",
      newCommandTimeout: "3600",
      automationName: "XCUITest",
      bundleId: "ca.bc.gov.pathfinder.mobile.MyRA",
      xcodeOrgId: "TCH45SXZ69",
      xcodeSigningId: "iPhone Developer",
      udid: "188a02f046140e509cd7082b7e974487be8a4dea" ,
      platformVersion: "11.3",
      setWebContentsDebuggingEnabled: "true"
      # noReset: "true",
      # fullReset: "false",
      # showIOSLog: "true",
      # autoAcceptAlerts: "true",
      # showXcodeLog: "true",
      # useNewWDA: "true",
      # resetOnSessionStartOnly: "true"
    }
  }
end


@caps_ipad_sim = caps_ipad_sim
@caps_ipad = caps_ipad
# @caps_android_bs = caps_android_bs
# @caps_android_emulator = caps_android_emulator
