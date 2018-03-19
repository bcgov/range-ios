import geb.spock.GebReportingSpec
import spock.lang.*

import pages.app.*
import pages.external.*

@Title(" Login ")
@Narrative("""
At Login page, I should be able to click on Login button and redirected to login webview using IDIR account.
""")
@See("?")
@Stepwise
class LoginSpec extends GebReportingSpec {

    def "Scenario: 1 - Go to website for the first time"(){
        given: "I am an application administrator"
        to LoginPage

        when: "I access the website"
        titleText == "My Range App"

        and: "I click on the login button"
        loginButton.click()

        then: "I should be redirected to login webview using IDIR account"
        at IDIRPage

    }

    def "Scenario: 2 - Login with IDIR account"(){
        given: "I am at the redhat page"
        at IDIRPage

        when: "I enter the IDIR account username and password"
        IDIRusername = "test"
        IDIRpassword = "test"

        and: "I click on submit"
        loginButton.click()

        then: "I should be redirected to the Home page"
        at HomePage
    }


    def "Scenario: 3 - Search agreements"(){
        given: "I am at the Home page"
        at HomePage

        when: "I enter in the search field"
        searchField.value("yes")

        and: "I hit enter"
        sleep(1000)

        then: "I should see the filtered list"
        at HomePage
    }
}
