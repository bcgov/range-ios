import geb.spock.GebReportingSpec
import spock.lang.*

@Title(" Login to teh")
@Narrative("""<No Narritive yet>""")
@See("?")
class LoginSpec extends GebReportingSpec {

    @Unroll
    @Ignore("TODO")
    @Issue("?")
    def "Scenario: 1 - Go to website for the first time"(){
        given: "I am an application administrator"
        when: "I access the website"
        and: "I click on the login button"
        then: "I should be redirected to login webview using IDIR account"
    }



    def "Scenario: 2 - Login with IDIR account"(){
        given: "I am at the redhat page"
        when: "I enter the IDIR account username and password"
        and: "I click on submit"
        then: "I should be redirected to the Home page"
    }
}
