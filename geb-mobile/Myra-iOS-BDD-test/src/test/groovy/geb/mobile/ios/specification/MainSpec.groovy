package geb.mobile.ios.specification

import geb.mobile.ios.views.CreateView
import geb.mobile.ios.views.HomeView
import geb.spock.GebSpec

/**
 * Created by gmueksch on 01.09.14.
 */

/**
 * Sample test case for iOS app calculator native app:
 */

class MainSpec extends GebSpec {

    def "open app to the Home page"(){
        Given: "Land on home page"
        at HomeView

        When:"I see the table"
        rangeTable

        And: "Click on create new RUP button"
        createButton
        // .click()
        createButton2

        Then: "I should be in Create page"
        at CreateView
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
