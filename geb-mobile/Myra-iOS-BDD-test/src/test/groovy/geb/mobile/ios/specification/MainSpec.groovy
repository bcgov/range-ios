package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.*

import geb.mobile.ios.views.CreateView
import geb.mobile.ios.views.HomeView
import geb.mobile.ios.views.AgreementSelectionView
import geb.mobile.ios.views.PopUpNameView



@Title("Test #2 - v1")
@Narrative("""
Only including the positive user story for test cases.
Standard procedure of app usage on the Home page: (and general navigation)
- Verify the app and data status
- See a list of assigned agreements
- Create a new RUP and save
- Logout
""")


@Stepwise
class MainSpec extends GebMobileBaseSpec {

    def "Open app to the Home page for list of assigned agreements"(){
        given: "Land on Home page"
        at HomeView

        when: "I see the table and create button"
        rangeTable
        createButton

        then: "I should see cells in the table with different status"
        rangeTableCells.size() == 21
        completedTableCells.size() == 11

    }

    def "Verify internet mode"(){
        given: "I am on Home page"
        at HomeView

        when: "I turn off wifi on device"


        then: "I should be in OFFLINE mode"

    }

    def "Verify internet mode 2"(){
        given: "I am on Home page"
        at HomeView

        when: "I turn on wifi on device"


        then: "I should be in ONLINE mode"

    }
//    ------------------------------------------------------------------------in a new spec...


    def "Create a new RUP and save"(){
        given: "I am on Home page"
        at HomeView

        when: "I click on create button"
        createButton.click()

        and: "I am at the Agreement Selection page"
        at AgreementSelectionView

        and: "I pick an agreement"
        firstAgreement.click()

        then: "I should be in the Create page"
        at CreateView
    }

    def "check auto-populated fields in agreement for RUP"(){
        given: "I am on Create page"
        at CreateView

        when: "I have the Agreement selected"
//        rangeNumberField == "xxx"

        then: "I should see all the existing fields"
//        check the rest with data table
        targetField == expectedInfo


    }


    def "create new <Basic Information> session in RUP"(){
        given: "I am on Create page"
        at CreateView

        when: "I click on Add button"
        createButton.click()

        and: "I am at the Agreement Selection page"
        at AgreementSelectionView

        and: "I pick an agreement"
        firstAgreement.click()

        then: "I should see the section populated"
        at CreateView
    }

    def "create new <Range Usage> session in RUP"(){
        given: "I am on Create page"
        at CreateView

        when: "I click on create button"
        createButton.click()

        and: "I am at the Agreement Selection page"
        at AgreementSelectionView

        and: "I pick an agreement"
        firstAgreement.click()

        then: "I should be in the Create page"
        at CreateView
    }

    def "create new <LiveStock ID> session in RUP"(){
        given: "I am on Create page"
        at CreateView

        when: "I click on create button"
        createButton.click()

        and: "I am at the Agreement Selection page"
        at AgreementSelectionView

        and: "I pick an agreement"
        firstAgreement.click()

        then: "I should be in the Create page"
        at CreateView
    }

    def "create new <Pastures> session in RUP"(){
        given: "I am on Create page"
        at CreateView

        when: "I click on create button"
        createButton.click()

        and: "I am at the Agreement Selection page"
        at AgreementSelectionView

        and: "I pick an agreement"
        firstAgreement.click()

        then: "I should be in the Create page"
        at CreateView
    }

    def "create new <Yearly Schedules> session in RUP"(){
        given: "I am on Create page"
        at CreateView

        when: "I click on create button"
        createButton.click()

        and: "I am at the Agreement Selection page"
        at AgreementSelectionView

        and: "I pick an agreement"
        firstAgreement.click()

        then: "I should be in the Create page"
        at CreateView
    }

    def "status update on the sidebar for RUP creation"(){

    }

    def "Save a RUP to draft and re-access"(){

    }


    def "Submit a new RUP"(){

    }

}
