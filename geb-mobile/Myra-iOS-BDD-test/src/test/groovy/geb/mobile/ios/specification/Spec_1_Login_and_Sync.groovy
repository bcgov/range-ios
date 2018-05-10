package geb.mobile.ios.specification

import geb.mobile.GebMobileBaseSpec
import spock.lang.*
import geb.mobile.ios.views.Login.LoginWebView
import geb.mobile.ios.views.Login.LoginView
import geb.mobile.ios.views.HomeView
import geb.mobile.ios.views.SyncPopUpView

@Title("Test #1 - v1")
@Narrative("""
Only including the positive user story for test cases.
First time log in to the app will require:
1. Login with IDIR account
2. Syncing the data from server
""")

@Stepwise
class Spec_1_Login_and_Sync extends GebMobileBaseSpec {

//    @Ignore("Only the first time usage")
    def "S-1: Open app and sign in"() {
        given: "Open the app for the first time"
        setNativeContext()
        at LoginView
        sleep(1000)

        when: "I click on login button"
        loginButton.click()
        sleep(10000)

        and: "(switch app context to webview)"
        setWebViewContext()

        then: "I should be redirected to IDIR Login page"
        at LoginWebView
    }

    @Ignore("Token valid but not yet used the app")
    def "S-1: Open app and login before token expire"() {
        given: "Open the app for the first time"
        setNativeContext()
        at LoginView

        when: "I click on login button and wait for syncing"
        loginButton.click()
        sleep(5000)

        then: "I should be redirected to Home page"
        at HomeView

    }

    @Ignore("Token valid and goes to home page right away")
    def "S-1: Open app and go to Home page and Sync"() {
        given: "I'm at Home page"
        setNativeContext()
        at HomeView
        sleep(1000)

        when: "I click on Sync button"
        syncButton.click()
        sleep(5000)

        then: "I should see sync successful"
        setWebViewContext()
        sleep(5000)
        at LoginWebView

    }


//    @Ignore("Only the first time usage")
    def "S-1.1: Login with IDIR account"() {
        given: "I am at the Login website"
        at LoginWebView
        sleep(5000)

        when: "I enter my IDIR account"
        usernameField = "myra2"
        passwordField = "myra2"

        and: "I click on IDIR login button"
        IDIRloginButton.click()
        sleep(5000)

        and: "(switch app context to native)"
        setNativeContext()

        then: "I should be directed to Home page with syncing"
        at SyncPopUpView
    }

    @Ignore("Wait for accessibility ID for status")
    def "S-2: Status are updated after sync"() {
        given: "I'm at Sync page"
        at SyncPopUpView

        when: "Syncing is done and close pop up window"
        closePopUpButton.click()

        then: "I am directed to the Home page with synced status"
        at HomeView
//        assert syncStatusField

    }

    @Ignore("Verified manually")
    def "S-2.1: Sync will fail when no internet connection"() {
        given: "I'm at Sync page already"
        when: "I turn on Airplane Mode"
//        https://appium.io/docs/en/commands/device/network/toggle-airplane-mode/
        then: "I should see Sync fails"
    }


    @Ignore("Verified manually")
    def "S-2.2: Sync will pass when internet connection is back"() {
        given: "I'm at Sync page already"
        when: "I turn off Airplane Mode"
        and: "I am in ONLINE mode and sync again"
        then: "I should see Sync successful"
    }
}