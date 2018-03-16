package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.*
import geb.mobile.ios.views.LoginView
import geb.mobile.ios.views.HomeView
import geb.mobile.ios.views.Sync.SyncView
import geb.mobile.ios.views.Sync.SyncSuccess



@Title("Test #1 - v1")
@Narrative("""
Only including the positive user story for test cases.
First time log in to the app will require:
1. Login with IDIR account
2. Syncing the data from server
""")


@Stepwise
class LoginSpec extends GebMobileBaseSpec {

    def "open app for the first time"() {
        given: "Open the app"
        at LoginView

        when: "I am at Login page"

        and: "I enter my IDIR account and submit"

        and: "I am redirected to Sync page"
        at SyncView

        and: "I am in ONLINE mode and wait for sync"
        sleep(5000)

        then: "I should be in Syncing Complete page"
        at SyncSuccess

    }

    def "Entering the Home page of the app"() {
        given: "Syncing data"
        at SyncSuccess

        when: "I click on Continue button"
//        continueButton.click()

        then: "I am directed to the Home page with synced status"
        at HomeView
//        check sync timestamp

    }


}