package geb.mobile.android

import geb.Browser
import groovy.util.logging.Slf4j
import io.appium.java_client.AppiumDriver
import io.appium.java_client.android.StartsActivity
import io.appium.java_client.android.Activity
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.AndroidElement
import io.appium.java_client.android.AndroidKeyCode
import org.openqa.selenium.WebDriver
import org.openqa.selenium.interactions.Actions
import io.appium.java_client.TouchAction
import org.openqa.selenium.By

import java.time.Duration

/**
 * Provides some basic Androrid
 * Created by gmueksch on 21/01/15.
 */

/**
 * TODO:
 * keycodes
 * swipe
 * multi-touch
 *
 */

@Slf4j
class AndroidHelper {

    private Browser browser
    static Duration actionDuration = Duration.ofMillis(200)

    private WebDriver getDriver(){
        browser.driver
    }

    void back() {
        driver.pressKeyCode(AndroidKeyCode.BACK)
    }
    void menu() {
        driver.pressKeyCode(AndroidKeyCode.MENU)
    }
    void home() {
        driver.pressKeyCode(AndroidKeyCode.HOME)
    }
    void recents() {
        driver.pressKeyCode(AndroidKeyCode.KEYCODE_APP_SWITCH)
    }

    /**
     * static method for usage in Navigator
     * @param driver
     */

    public String getMessage(){
        browser.find("#android:id/message").text()

    }

    /**
     * Click the Retry on the modal system message dialogo
     * first looks for resource-id button1, than for retry with caseinsesitivenes
     * @return
     */
    public def systemRetry(){
        def button = browser.find("#android:id/button1")
        if( button.size()==0 )
            button = browser.find("#textMatches('(?i:retry)')")
        if( button.size()==0 )
            button = browser.find("#textMatches('(?i:try again)')")

        button.click()

    }

    /**
     * Click the Retry on the modal system message dialogo
     * first looks for resource-id button2, than for cancel with caseinsesitivenes
     * @return
     */
    public def systemCancel(){
        def button = browser.find("#android:id/button2")
        if( button.size()==0 )
            button = browser.find("#textMatches('(?i:cancel)')")

        button.click()
    }

    /**
     * Handles a system message modal dialog
     * Reads the message, then presses retry(default) or cancel if available
     * @param retry defaults to true
     * @return the system message
     */
    public String handleSystemMessage(def retry = true ){
        def msg = getMessage()
        if( msg )
            log.info("Got System Message popup: '$msg' ")
        else
            return null

        if( msg == "We have encountered a network communication problem" ) {
            retry ? systemRetry() : systemCancel()
        }else if( msg == "No internet connection available"){
            retry ? systemRetry() : systemCancel()
        }else if( msg =~ /previous crashes/ ){
            retry ? systemRetry() : systemCancel()
        }

        return msg
    }
    /**
     * Swipe the screen to left, scrollable object should be visible
     * uses window().size to figure the start and end points
     * @return
     */
    public boolean swipeToLeft() {
        def dim = driver.manage().window().size
        int startX = dim.width - 5
        int startY = dim.height / 2
        int endX = 5
        int endY = startY
        try {
            TouchAction swipeAction = new TouchAction(driver).press(startX, startY).waitAction(actionDuration).moveTo(endX, endY).release()
            swipeAction.perform()
            return true
        } catch (e) {
            log.warn("Error on swipe left($startX, $startY, $endX, $endY, 200) : $e.message")
        }

        false

    }

    /**
     * Swipe the screen to right, scrollable object should be visible
     * uses window().size to figure the start and end points
     * @return
     */
    public boolean swipeToRight() {
        def dim = driver.manage().window().size
        int startX = 5
        int startY = dim.height / 2
        int endX = dim.width - 5
        int endY = startY
        try {
            TouchAction swipeAction = new TouchAction(driver).press(startX, startY).waitAction(actionDuration).moveTo(endX, endY).release()
            swipeAction.perform()
            return true
        } catch (e) {
            log.warn("Error on swipe right($startX, $startY, $endX, $endY, 200) : $e.message")
        }
        false
    }

    public boolean swipeUp() {
        def dim = driver.manage().window().size
        int startX = dim.width / 2
        int startY = dim.height / 2
        int endX = startX
        int endY = dim.height -5
        try {
            TouchAction swipeAction = new TouchAction(driver).press(startX, startY).waitAction(actionDuration).moveTo(endX, endY).release()
            swipeAction.perform()
            return true
        } catch (e) {
            log.warn("Error on swipe to top($startX, $startY, $endX, $endY, 200) : $e.message")
        }
        false
    }

    public boolean swipeDown() {
        def dim = driver.manage().window().size
        int startX = dim.width / 2
        int startY = dim.height - 5
        int endX = startX
        int endY = dim.height / 2
        try {
            TouchAction swipeAction = new TouchAction(driver).press(startX, startY).waitAction(actionDuration).moveTo(endX, endY).release()
            swipeAction.perform()
            return true
        } catch (e) {
            log.warn("Error on swipe to the bottom ($startX, $startY, $endX, $endY, 200) : $e.message")
        }
        false
    }


    public boolean isOnListView(){
        driver.findElements(By.xpath("//android.widget.FrameLayout/android.widget.ListView")).size() == 1
    }

//Use BACK() for closing elements:
    public boolean closeListView(){
        if( isOnListView() ) back()
    }


    boolean switch2Settings() {
        try {

            Activity act = new Activity("com.android.settings", "com.android.settings.Settings")
            act.setStopApp(false)
            driver.startActivity(act)
            return true
        }
        catch (e) {
            log.warn("Error change apps: $e.message")
        }
        false
    }


    boolean switch2App() {
        try {

            Activity act = new Activity("ca.bc.gov.secureimage", "ca.bc.gov.secureimage.screens.authenticate.AuthenticateActivity")
            act.setStopApp(true)
            driver.startActivity(act)
            return true
        }
        catch (e) {
            log.warn("Error change apps: $e.message")
        }
        false
    }

    boolean unLockDevice() {
        try {
            driver.unlockDevice()
            log.info("Unlock device.")
            return true
        }
        catch (e) {
            log.warn("Error change apps: $e.message")
        }
        false
    }

    boolean lockDevice() {
        try {
            driver.lockDevice()
            log.info("Device locked.")
            return true
        }
        catch (e) {
            log.warn("Error change apps: $e.message")
        }
        false
    }


}
