package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.Stepwise

import geb.mobile.ios.views.CreateView
import geb.mobile.ios.views.HomeView

/**
 * The positive user story test cases:
 */

@Stepwise
class MainSpec extends GebMobileBaseSpec {

    def "open app to the Home page"(){
        given: "Land on home page"
        // at HomeView
        sleep(10)

        when: "I see the table"
        rangeTable

        and: "Click on create new RUP button"
        createButton
        // createButton2

        then: "I should be in Create page"
        // at CreateView
        sleep(10)
    }


    
// // sample test case:
//     def "open test-app and test sum of two numbers"(){
//         given: "Land on home page"
//         at UICatalogAppView

//         when:"Enter two numbers"
//         insertTextElement1 = "12"
//         insertTextElement2 = "22"

//         and: "Click on sum up button"
//         sumElement.click()

//         then: "Check result"
//         resultField == "34"
//     }
}
