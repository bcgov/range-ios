package geb.mobile.driver

import groovy.util.logging.Slf4j
import io.appium.java_client.AppiumDriver
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.AndroidElement
import io.appium.java_client.ios.IOSDriver
import io.appium.java_client.ios.IOSElement
import org.openqa.selenium.Platform
import org.openqa.selenium.firefox.FirefoxDriver
import org.openqa.selenium.remote.DesiredCapabilities
import org.openqa.selenium.remote.LocalFileDetector
import org.openqa.selenium.remote.RemoteWebDriver

/**
 * Created by gmueksch on 12.08.14.
 */


/**
 * Shelly notes:
 * Configure drivers:
 * ----- Appium ----- (Appium drivers replaced the platform specific selendroid and uiautomation drivers)
 * iOS
 *   The XCUITest Driver        9.3+
 *   The UIAutomation Driver    8.0-9.3
 *
 * Android
 *   (BETA) The Espresso Driver
 *   The UiAutomator2 Driver
 *   (DEPRECATED) The UiAutomator Driver
 *   (DEPRECATED) The Selendroid Driver
 *
 * The Windows Driver (for Windows Desktop apps) (not implemented)
 *
 * The Mac Driver (for Mac Desktop apps) (not implemented)
 *
 *
 * ----- Selenium -----
 * Firefox
 *
**/
@Slf4j
class GebMobileDriverFactory {

    public static String FRAMEWORK_APPIUM = "appium"
    public static String FRAMEWORK_SELENIUM = "selenium"

    public static URL getURL(String url) {
        String appiumUrl = System.getProperty("appium.url")
        if (appiumUrl) return new URL(appiumUrl)
        else return new URL(url)
    }

    public static RemoteWebDriver createMobileDriverInstance() {
        log.info("Create Mobile Driver Instance for Framework ${System.properties.framework} ... ")

//      Appium Driver:
        if (useAppium()) {
            DesiredCapabilities capa = new DesiredCapabilities()
            //set default platform to android
            capa.setCapability("platformName", "Android");

            System.properties.each { String k, v ->
                def m = k =~ /^appium_(.*)$/
                if (m.matches()) {
                    log.info "setting appium property: $k , $v"
                    capa.setCapability(m[0][1], v)
                }
            }
            def driver
//          Android:
            if (capa.getCapability("platformName") == "Android") {
                capa.setCapability("platform", Platform.ANDROID)
                if( appPackage() ) capa.setCapability("appPackage", appPackage())
                if (!capa.getCapability("deviceName")) capa.setCapability("deviceName", "Android");

                log.info("Create Appium Android Driver ")
                try {
                    driver = new AndroidDriver<AndroidElement>(getURL("http://0.0.0.0:4723/wd/hub"), capa)
                    //driver.setFileDetector(new LocalFileDetector())
                    //sleep(1000)
                    log.info("Driver created: $driver.capabilities")
                    return driver
                } catch (e) {
                    //
                    log.error("eXC: $e.message", e)
                }
            }
//          iOS:
            else{
                log.info("Create Appium IOSDriver ")
                driver = new IOSDriver<IOSElement>(getURL("http://0.0.0.0:4723/wd/hub"), capa)
                driver.setFileDetector(new LocalFileDetector())
                return driver

            }

            if (!driver) throw new RuntimeException("Appium Driver could not be started")
        }
//      Web Driver:
        else if (System.properties.framework == FRAMEWORK_SELENIUM) {
            DesiredCapabilities capa = DesiredCapabilities.firefox()
            System.properties.each { String k, v ->
                def m = k =~ /^selenium_(.*)$/
                if (m.matches()) {
                    log.info "setting Web property: $k , $v"
                    capa.setCapability(m[0][1], v)
                }
            }
            def selenium = new RemoteWebDriver(getURL("http://0.0.0.0:4723/wd/hub"),capa)
            selenium.setFileDetector(new LocalFileDetector())
            return selenium
        }
//      Unrecognized Driver: (deprecated)
        else {
            throw new Exception("Set Systemproperty 'framework' to appium or selenium")
        }

    }

    public static boolean useAppium() {
        System.properties.framework == FRAMEWORK_APPIUM
    }

    public static String appPackage() {
        System.properties.'appUT.package'
    }

    public static String appVersion() {
        System.properties.'appUT.version'
    }

    /*  Test Helper Methods */
    /**
     *
     * @param framework
     * @param map the capabilities to add
     */
    public static void setFrameWork(String framework, def map = null) {
        System.setProperty("framework", framework)
        map?.each { k, v ->
            def key = "${framework}_${k}"
            if (k in ['appUT.package', 'appUT.version']) System.setProperty(k, v)
            else if(System.getProperty(key,null)==null) System.setProperty(key, v)
        }
    }

    /**
     * Convinient Method to set Framework and Capabilities for ...
     * @param map
     */
    public static void setAppium(def map) {
        setFrameWork(FRAMEWORK_APPIUM, map)
    }

    public static void setAppiumAndroid(def map = []){
        map.platformName = map.platformName ?: 'Android'
        map.appActivity = map.appActivity ?: "MainActivity"
        setAppium(map)
    }

    /**
     * Convinient Method to set Framework and Capabilities for ...
     * @param map
     */
    public static void setAppiumIos(def map) {
        if (!map) map = []
        map.platformName = map.platformName ?: 'iOS'
        map.deviceName = map.deviceName ?: 'iPhone 6'
        setFrameWork(FRAMEWORK_APPIUM, map)
    }


}
