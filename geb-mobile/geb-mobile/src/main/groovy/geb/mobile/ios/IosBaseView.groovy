package geb.mobile.ios

import geb.Page
import groovy.util.logging.Slf4j
import io.appium.java_client.ios.IOSDriver
import io.appium.java_client.TouchAction
import org.openqa.selenium.ScreenOrientation
import org.openqa.selenium.WebElement

import java.util.concurrent.TimeUnit

/**
 * Created by gmueksch on 27.08.14.
 *
 * Shelly notes:
 * Limitation on iOS devices:
 * 1. cannot get hte activity/view name for current page
 * 2. cannot bring up the general settings, such as the airplane mode
 * 3. cannot Lock screen
 *
 *
 */
@Slf4j
class IosBaseView extends Page {

    static content = {
    }

    static at = {
// iOS does not have concept as activity/page/view, just returning True.
// The actual check would be by a specific element in the page
//        getCurrentView() ? currentView == getCurrentView() : true
        true
    }

    def executeTargetFunc( func ){
        try {
            ((IOSDriver) driver).findElementsByIosUIAutomation("var target = UIATarget.localTarget();target.$func")
        }catch(e){
            log.error("Error on target Function $func: $e.message")
        }
    }

// ORIENTATION --------------------------------------------------------:
    void switchOrientation( orientation ) {
        if (driver instanceof IOSDriver) {
            if (orientation == ScreenOrientation.LANDSCAPE && driver.orientation != orientation) {
                log.info("Switch orientation to $orientation")
                executeTargetFunc('setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT)')

            } else if( orientation == ScreenOrientation.PORTRAIT && driver.orientation != orientation) {
                executeTargetFunc('setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT)')
            }
        }
    }

    //To be LANDSCAPE or PORTRAIT:
    boolean checkOrientation( orientation ) {
        if (((IOSDriver) driver).orientation != orientation) {return true}
        false
    }





// TAP --------------------------------------------------------:
//by coordinates:
//    void coordinateTap(int x, int y) {
//            TouchAction action = new TouchAction(((IOSDriver) driver))
//            action.tap(x,y)
//            action.perform()
//    }


// CONTEXT --------------------------------------------------------:
// there are ["NATIVE_CONTEXT", "WEBVIEW_1", "WEBVIEW_2"...]
// This need to enable <setWebContentsDebuggingEnabled>

    void setNativeContext(){
        ((IOSDriver) driver).context("NATIVE_APP")
    }

    void getContexts(Set contextNames){
        System.out.println("There are "+contextNames.size()+" contexts:")
        for (String curContext : contextNames) {
            System.out.println(curContext)
        }
    }

    void setWebViewContext(){
        log.info("Before switch context is "+ ((IOSDriver) driver).getContext())
        try {
            Thread.sleep(1500)
        } catch (InterruptedException e) {
            e.printStackTrace()
        }
        Set contextNames = ((IOSDriver) driver).getContextHandles()
        if(contextNames.size() < 2) {
            log.info("Only one context available, cannot switch!")
            return
        } else {
            getContexts(contextNames)
            driver.manage().timeouts().implicitlyWait(1, TimeUnit.SECONDS)//???????why need the wait????
//TODO: https://github.com/appium/appium/issues/10059
            //Set the context specified:
            ((IOSDriver) driver).context(contextNames[1])
            log.info("After switch is "+((IOSDriver) driver).getContext())
            return
        }
    }

//To add for web view:
//    public String getCurrentView() {
//        return driver.currentUrl
//    }



// HARDWARE --------------------------------------------------------:
//This is not available for ios, action forbidden!
//    boolean AirPlaneMode() {
//        try {
//            driver.toggleAirplaneMode()
//            return true
//        }
//        catch (e) {
//            log.warn("Error change apps: $e.message")
//        }
//        false
//    }



// KEYBOARD --------------------------------------------------------:
    void back() {
        ((IOSDriver) driver).navigate().back()
    }

    void hideKeyboard() {
        ((IOSDriver) driver).hideKeyboard()
    }

    void restart(){
        ((IOSDriver) driver).resetApp()
    }
}
