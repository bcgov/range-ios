package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.*
import geb.mobile.ios.views.HomeView

@Title("Test #2 - v1")
@Narrative("""
Only including the positive user story for test cases.
Standard procedure of app usage on the Home page: (and general navigation)
- Verify the app and data status
- See a list of assigned agreements
- Logout
""")



//TODO: will not include the RUP creation test cases till it's at a more stable phase
//TODO: Back() --> DONE
//TODO: add the 'to' method to direct to a specific activity  --> cannot do for ios



@Ignore
@Stepwise
class Spec_2_Main_Page extends GebMobileBaseSpec {

//    @Ignore("TODO")
    def "S-5: Open app to the Home page for list of assigned agreements"(){
        given: "Land on Home page"
        at HomeView
        sleep(1000)

        when: "I see the table and create button"
        assert rangeTable
//        createButton

        then: "I should see cells in the table with different status"
//        rangeTableCells.size() == 21
//        completedTableCells.size() == 11

    }

    @Ignore("TODO")
    def "S-5.1: View the details of an agreement from the list of assigned agreements"(){
        given: "Land on Home page"
        at HomeView
        sleep(1000)
        when: "I click on View button for an agreement"

        then: "I should see the details in View (Create) page"
//        at CreatePage

    }

    @Ignore("Verified manually")
    def "S-6.1: Verify internet mode"(){
        given: "I am on Home page"
        at HomeView

        when: "I turn on Airplane Mode in device"
//        sleep(2000)

        then: "I should be in OFFLINE mode"

    }

    @Ignore("Verified manually")
    def "S-6.2: Verify internet mode 2"(){
        given: "I am on Home page"
        at HomeView

        when: "I turn off Airplane Mode in device"
        sleep(2000)

        then: "I should be in ONLINE mode"

    }

    @Ignore("Wait for feature implementation")
    def "S-7: Logout of app"(){
        given: "I am on Home page"
        at HomeView

        when: "I click on logout button"

        then: "I should be in Login page again"

    }
}
