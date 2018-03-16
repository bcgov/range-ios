package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.*

import geb.mobile.ios.views.CreateView
import geb.mobile.ios.views.HomeView
import geb.mobile.ios.views.AgreementSelectionView
import geb.mobile.ios.views.PopUpNameView



@Title("Test #1 - v1")
@Narrative("""
Only including the positive user story for test cases.
- standard procedure of app usage
- Create a new RUP with all information
- Save and reaccess
- Submit and verify the status change
""")


@Stepwise
class MainSpec extends GebMobileBaseSpec {

    def "open app to the Home page"(){
        given: "Land on Home page"
        at HomeView

        when: "I see the table and create button"
        rangeTable
        createButton

        then: "I should see cells in the table with different status"
        rangeTableCells.size() == 21
        completedTableCells.size() == 11

    }

    def "create new RUP"(){
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
