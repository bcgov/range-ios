package geb.mobile.android.specification

import geb.mobile.GebMobileBaseSpec
import geb.mobile.android.activities.HomeScreenActivity
import geb.mobile.android.activities.CameraActivity
import geb.mobile.android.activities.FirstTimeLoginActivity
import geb.mobile.android.activities.AlbumCreationActivity
import geb.mobile.android.activities.TakeImageActivity
import geb.mobile.android.activities.ViewAllImageActivity
import geb.mobile.android.activities.ChromSigninActivity
import geb.mobile.android.activities.AccessPermissionActivity
import geb.mobile.android.activities.RedirectActivity
import geb.mobile.android.activities.SettingsActivity


import spock.lang.Stepwise


/**
 * Created by gmueksch on 23.06.14.
 */



/**
 * Sample test case for android app on Wiki native app:
 * TODO: rename activity to match the app's current activity
 */
@Stepwise
class GebMobileAutomationTestWithPagesSpec extends GebMobileBaseSpec {

    def "0. Set screen lock PIN in settings"() {
        given: "I go to settings"
        at SettingsActivity

        when:
        lockTab.click()
        sleep(500)

        and:
        lockType.click()
        sleep(500)
        pinOptions.click()
        sleep(500)
        pinField = "123456"
        sleep(500)

        and:
        nextButton.click()

        and:
        pinField = "123456"
        nextButton.click()

        then:
        switchToAPP

    }

//    def "1. First time login to the app"() {
//        given: "I open the app"
//        at FirstTimeLoginActivity
//        switchApp
//        sleep(1000)
//
//        when:
//        at SettingsActivity
//        lockTab.click()
//        sleep(500)
//
//        and:
//        lockType.click()
//        sleep(500)
//        pinOptions.click()
//        sleep(500)
//        pinField = "123456"
//        sleep(500)
//
//        and:
//        nextButton.click()
//
//        and:
//        pinField = "123456"
//        nextButton.click()
//
//        and:
//        switchApp2
//        sleep(500)
//
//
//
//        then: "I should see the homepage to create album"
//        at FirstTimeLoginActivity
//        authenticateButton.click()
//        sleep(1000)
//
//    }

    def "1. First time login to the app"() {
        given: "I open the app"
        at FirstTimeLoginActivity

        when: "I click on the auth button"
        authenticateButton.click()
        sleep(500)

        and: "I type in password to unlock and continue"
//        this is the device password
        passwordField = "123456"
        sleep(500)
        nextButton.click()
        sleep(500)

        and: "I see the camera access request message and allow"
        at AccessPermissionActivity
        allowAccessButton.click()
        sleep(1000)

        then: "I should see the homepage to create album"
        at HomeScreenActivity
        createAlbumButton.click()
    }

    def "2. Create empty albums"() {
        given: "I am at the create album page"
        at AlbumCreationActivity

        when: "I click on the back button"
        backButton.click()

        and:
        at HomeScreenActivity
        createAlbumButton.click()

        and:
        at AlbumCreationActivity
        backButton.click()
        sleep(1000)

        then: "I should see the homepage to create album"
        at HomeScreenActivity
        assert albums.size() >= 1
        createAlbumButton.click()
    }


    def "3. Create an album"() {
        given: "I am at the create album page"
        at AlbumCreationActivity

        when: "I click on the add image button"
        addImageButton.click()

        and:
        at AccessPermissionActivity
        allowAccessButton.click()
        sleep(3000)

        and:
        at TakeImageActivity
        shutterButton.click()
        sleep(500)
        shutterButton.click()
        sleep(500)
        backButton.click()
        sleep(500)


        and:
        at AlbumCreationActivity
        uploadButton.click()
        sleep(1000)

        then: "I should see the page to redirect to webview"
        at RedirectActivity
        loginButton.click()

    }







//    def "test camera and take photo"() {
//        given: "open the camera"
//        sleep(3000)
//        at CameraActivity
//
//        when: "I enable the location request"
//        acceptButton.click()
//
//        and: "I click on the shutter button"
//        sleep(1000)
//        shutterButton.click()
//
//        then: "I should have the camera ready again"
//        preview
//    }
}
