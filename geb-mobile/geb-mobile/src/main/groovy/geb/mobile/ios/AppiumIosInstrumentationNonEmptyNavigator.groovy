package geb.mobile.ios

import geb.Browser
import geb.mobile.AbstractMobileNonEmptyNavigator
import geb.navigator.EmptyNavigator
import geb.navigator.Navigator
import groovy.util.logging.Slf4j
import io.appium.java_client.MobileElement
import io.appium.java_client.ios.IOSDriver
import io.appium.java_client.ios.IOSElement
import org.apache.commons.lang3.NotImplementedException
import org.openqa.selenium.By
import org.openqa.selenium.WebElement
import org.openqa.selenium.WebDriver

/**
 * Created by gmueksch on 23.06.14.
 *
 *
 * Shelly notes:
 * -> Locator strategies
 * From Appium:
 *      className           -- starting with "XCUIElementType-xxx"
 *      xpath               -- from XML page source
 *
 * From WebDriver:
 *      CssSelector         -- Starting with @
 *
 *  From the platform specific:
 *      .findElementsByIosUIAutomation()     -- using the iOS Instruments framework
 *
 *  From general:
 *      accessibility id    -- the resource-id attribute (different from Android)
 *      id                  -- name
 *      name                -- TODO: ?difference with id?
 *
 **/

@Slf4j
class AppiumIosInstrumentationNonEmptyNavigator extends AbstractMobileNonEmptyNavigator<IOSDriver<IOSElement>> {

    AppiumIosInstrumentationNonEmptyNavigator(Browser browser, Collection<? extends MobileElement> contextElements) {
        super(browser,contextElements)
    }

//    static def pat = ~/(\w+)='(.+)'?/

    @Override
    Navigator find(String selectorString) {
        log.debug "Selector: $selectorString"

        //XPath:
        if( selectorString.startsWith("//") ) {
           log.info "Using Xpath"
            return navigatorFor(browser.driver.findElements(By.xpath(selectorString)))
        }

        String all,key,value
        if (selectorString.startsWith("#")) {
            value = selectorString.substring(1)
            //ClassName:
            if (value.startsWith("XCUIElementType") ||value.startsWith("UIA")) {
               log.info "Using className"
                return navigatorFor(driver.findElements(By.className(value)) )
            }
            //ID:
            else {
//TODO: figure out findElementsById or findElementsByIosUIAutomation
               log.info "Using ID"
                return (navigatorFor(driver.findElements(By.id(value))))
            }
        }

        //Css Selector (For webview):
        else if (selectorString.startsWith("@")) {
            log.info "Using cssSelector"
            value = selectorString.substring(1)
            return navigatorFor(driver.findElements(By.cssSelector(value)))
        }

        //Resource ID:
        else {
           log.debug("using uiautomation: $selectorString")
            try{
                return navigatorFor(driver.findElementsByIosUIAutomation(selectorString))
            }catch(e){
                log.warn("Selector $selectorString: findElementsByIosUIAutomation: $e.message")
                return new EmptyNavigator()
            }
        }
    }

    protected getInputValue(MobileElement input) {
        def value = null
        def type = input.getTagName()
        if (type == "UIASelect") {
            log.warn("Select not yet implemented, using fallback")
            value = getValue(input)
        } else if (type in ["UIACheckbox", "UIARadio"]) {
            if (input.isSelected()) {
                value = getValue(input)
            } else {
                if (type == "UIACheckbox") {
                    value = false
                }
            }
        } else {
            value = getValue(input)
        }
        value
    }

    @Override
    void setInputValue(MobileElement input, value) {
        def attrType = input.getTagName()
        if (attrType == "UIASelect") {
            setSelectValue(input, value)
        } else if (attrType == "UIACheckbox") {
            if (getValue(input) == value.toString() || value == true) {
                if (!input.isSelected()) {
                    input.click()
                }
            } else if (input.isSelected()) {
                input.click()
            }
        } else if (attrType == "UIARadio") {
            if (getValue(input) == value.toString() || labelFor(input) == value.toString()) {
                input.click()
            }
        } else if( attrType == 'UIASwitch' ) {
            String val = Boolean.valueOf(value) ? '1' : '0'
            if (getValue(input).toString() != val) {
                input.click()
            }
        } else if( attrType == 'UIAButton' ){
            boolean selected = input.isSelected()
            if( ( value && !selected ) || (!value && selected ) )
                input.click()

        } else {
            input.clear()
            input.sendKeys value as String
        }
    }

    protected getValue(WebElement input) {
        input?.getAttribute("value")
    }


    @Override
    boolean isEnabled() {
        return firstElement().enabled
    }

    @Override
    boolean isDisplayed() {
        return firstElement().displayed
    }

    @Override
    Navigator unique() {
        new AppiumIosInstrumentationNonEmptyNavigator(browser, contextElements.unique(false))
    }

    @Override
    Navigator leftShift(Object value) {
        throw new NotImplementedException()
    }

//    @Override
//    void scroll() {
//        driver.
//    }
}