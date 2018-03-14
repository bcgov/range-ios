package geb.mobile.android

import geb.Page
import io.appium.java_client.AppiumDriver
import io.appium.java_client.MobileElement
import io.appium.java_client.TouchAction
import io.appium.java_client.android.AndroidDriver
import io.appium.java_client.android.AndroidElement
import org.openqa.selenium.Dimension


/**
 * Base for AndroidActivities
 * - Provides auto at checker with the currentActivity
 * - back, menu and home action
 * - performTap
 * TODO: get rid of the 'instanceof', use mixin or traits, i'm still in the java-thinkin-way...
 *
 */
abstract class AndroidBaseActivity extends Page {

    //@Delegate(includes = ['back','menu','home'] )
    private AndroidHelper _helper

    static at = {
//        TODO: the actual activity is not matching the activities name:
//        getActivityName() ? currentActivity == getActivityName() : true
        getCurrentActivity() ? currentActivity == getCurrentActivity() : true
    }


    public AndroidHelper getHelper(){
        if( _helper == null )
            _helper = new AndroidHelper(browser:getBrowser())

        return _helper
    }

    void back() {
        helper.back()
    }
    void menu() {
        helper.menu()
    }
    void home() {
        helper.home()
    }
    void recents() {
        helper.recents()
    }


    /**
     * @return the Simple name of this Class, overwrite if classname is not the activityname, or null if it should not be checked
     */
    String getActivityName() {
        return this.getClass().getSimpleName()
    }


    /**
     * Special behavior for Appium
     * @return
     */
    public String getCurrentActivity() {
        if (driver instanceof AndroidDriver) {
            def currAct = driver?.currentActivity()
            if( !currAct ) return ''
            return currAct?.startsWith(".") ? currAct.substring(1) : currAct
        } else {
            def currUrl = driver.currentUrl
            return currUrl.startsWith("and-") ? currUrl.split(/\/\//)[1] : currUrl
        }
    }

    public Dimension getScreenDimension() {
        driver.manage().window().getSize()
    }

    public def getCameraShutterButtonCoordinates() {
        def dim = getScreenDimension()
        [dim.width - 100, dim.height / 2]
    }

    public boolean performTap(x,y){
        new io.appium.java_client.TouchAction(driver).tap(x.intValue(), y.intValue()).perform()
    }

    public MobileElement scrollTo(String text){
        if( driver instanceof AndroidDriver ){
            return driver.scrollTo(text)
//            return driver.findElementByAndroidUIAutomator(new UiScrollable(new UiSelector().scrollable(true).instance(0)).scrollIntoView(new UiSelector().textContains(\""+str+"\").instance(0))")
        }
        null
    }


//TODO: swipe left and right might not work when not supported by app, need to add check (notImplemented exception)
    boolean swipeUp() {
       return helper.swipeUp()
    }

    boolean swipeDown() {
        return helper.swipeDown()
    }

    boolean swipeToLeft() {
        return helper.swipeToLeft()
    }
    boolean swipeToRight() {
        return helper.swipeToRight()
    }


    boolean switch2Settings() {
        return helper.switch2Settings()
    }

    boolean switch2App() {
        return helper.switch2App()
    }


    boolean unLockDevice() {
        return helper.unLockDevice()
    }

    boolean lockDevice() {
        return helper.lockDevice()
    }


    public String getMessage(){
        $("#android:id/message").text()
    }

}
