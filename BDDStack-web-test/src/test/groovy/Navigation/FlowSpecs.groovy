import geb.spock.GebReportingSpec
import pages.app.*
import pages.external.*
import spock.lang.*

@Title("Basic Navigational Tests")
@Narrative("""As a user I expect all links in the Myra application to work.""")
class FlowSpecs extends GebReportingSpec {

    @Unroll
    def "Navigate Page from: #startPage, click Link: #clickLink, Assert Page: #assertPage"(){
	    given: "I start on the #startPage"
			to startPage
        when: "I click on the link #clickLink"
			waitFor { $("a", id:"$clickLink").click() }
        then:
			at assertPage

        where:
        startPage                   | clickLink                | clickCount    | timeoutSeconds    || assertPage
        LoginPage                  | "ribbon-groundwaterinfo" | 1             | 3                 || IDIRPage
        HomePage    		        | "ribbon-search"          | 1             | 3                 || PlanPage
        HomePage    		        | "ribbon-search"          | 1             | 3                 || ManageZonePage
        HomePage    		        | "ribbon-search"          | 1             | 3                 || LoginPage
        PlanPage                  | "BCWRAtlas"              | 1             | 3                 || HomePage
        ManageZonePage                  | "iMapBC"                 | 1             | 3                 || HomePage
    }
}
