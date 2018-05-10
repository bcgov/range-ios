package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.*
import geb.mobile.ios.views.HomeView

@Title("Test #3 - v1")
@Narrative("""
Only including the positive user story for test cases.
RUP creation:
- Create a new RUP with an agreement
- Enter information for sections: Basic Info, Pasture, Schedule
- Save RUP for later use
- Submit RUP
""")


//TODO: will not include the RUP creation test cases till it's at a more stable phase

@Ignore("TODO")
@Stepwise
class Spec_3_Create_Page extends GebMobileBaseSpec {

//    @Ignore("TODO")
    def "S-9: Create a new RUP from agreement I have"(){
        given: "I am on Home page"
        at HomeView
//        sleep(2180)

        when: "I click on create button"
//        createButton.click()

        and: "I am at the Agreement Selection page"
//        at AgreementSelectionView

        and: "I pick an agreement"
//        agreementList[0].click()

        then: "I should be in the Create page"
//        at CreateView
    }

//    @Ignore("TODO")
    def "S-9.1: check auto-populated fields in agreement for RUP"(){
        given: "I am on Create page"
//        at CreateView

        when: "I have the Agreement selected"
//        rangeNumberField == "xxx"

        then: "I should see all the existing fields"
//        check the rest with data table
//        targetField == expectedInfo

//        where:
//        targetField  | expectedInfo

    }

//    @Ignore("TODO")
    def "S-14.1: Edit dates in <Basic Information> session in RUP"(){
        given: "I am on Create page"
//        at CreateView

        when: "I click on Start-date of Plan"
//        startDatePlanField.click()
        sleep(1000)

        and: "I pick a date"
//        send value to three fields
        datePickers[0].send_key("May")
        datePickers[1].send_key("20")
        datePickers[2].send_key("2018")


        and: "I exit date picker"
        sleep(1000)

        and: "I enter End-date of Plan"
        sleep(1489)

        then: "I should see the dates updated in fields"
    }

//    @Ignore("TODO")
    def "S-14.2: Check <Range Usage> session in RUP"(){
//        given: "I am on Create page"
//        at CreateView

        when: "I am on Create page"
        then: "I should see a list of usages"
    }

    @Ignore("Wait for feature implementation")
    def "S-14.3: create new <LiveStock> session in RUP"(){
        given: "I am on Create page"
//        at CreateView

        when: "I click on add new items"
        and: "I enter info"
        and: "I duplicate item"
        and: "I delete the item"
        then: "I should see the fields updated"
    }

//    @Ignore("TODO")
    def "S-15.1: create new <Pastures> session in RUP"(){
        given: "I am on Create page"
//        at CreateView

        when: "I click on add new pasture"
        and: "I enter name"
//        and: "I duplicate item"
//        and: "I delete the item"
        then: "I should see the new pasture created"
    }

    @Ignore("TODO")
    def "S-15.2: enter info to <Pastures> session in RUP"(){
        given: "I am on Create page"
//        at CreateView

        when: "I have created a new pasture"
        and: "I enter allowable AUM's"
        and: "I enter private land deduction %"
        and: "I enter Grace Days"
        and: "I enter notes"
        then: "I should see the updated info"
    }

    @Ignore("TODO")
    def "S-16.1: create new <Yearly Schedules> session in RUP"(){
        given: "I am on Create page"
//        at CreateView

        when: "I click on add new year"
        and: "I enter info"
        and: "I duplicate item"
//        and: "I delete the item"
//        TODO: the detailed grazing schedule page????
        then: "I should see the fields updated"
    }

    @Ignore("TODO - including the rest of hte fields availabe")
    def "S-16.2: Update info of <Yearly Schedules> session in RUP - pasture field"(){
        given: "I am on Create page"
//        at CreateView

        when: "I have created a new schdule"
        and: "I click on it"
        and: "I click on pasture"
        then: "I should see pop up window"
        and: "I pick one and dismiss pop up"
//        TODO: the detailed grazing schedule page????
        then: "I should see the field updated"
    }

    @Ignore("Wait for feature implementation")
    def "S-9.2: status update on the sidebar for RUP creation"(){
        given: "I am on Create page"

        when: "I have filled in required sections in the form"

        then: "I should see checks in the sidebar sections"

    }

    @Ignore("TODO")
    def "S-9.3.1: Save a RUP to draft"(){
        given: "I am on Create page"

        when: "I click on Save button"

        then: "I should be directed back to Home page"

    }

    @Ignore("TODO")
    def "S-9.3.2: Re-access saved RUP"(){
        given: "I am on Home page"

        when: "I click on the previous RUP"

        then: "I should see the info still exists"

    }

    @Ignore("TODO")
    def "S-9.4: Submit a new RUP"(){
        given: "I am on Create page"

        when: "I click on Review and Submit button"

        then: "I should see my RUP is submitted and direct back to Home page"
    }

}