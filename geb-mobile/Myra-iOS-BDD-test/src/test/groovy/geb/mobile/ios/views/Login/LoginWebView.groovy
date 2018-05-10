package geb.mobile.ios.views.Login

import geb.mobile.ios.IosBaseView

class LoginWebView extends IosBaseView {

    static at = { title == "Log in to mobile"}
    static content = {

//        backButton {$("//XCUIElementTypeButton[@name=\"X\"]")}

        usernameField {$("@input[id='username']")}
        passwordField {$("@input[id='password']")}
        IDIRloginButton {$("@input[id='kc-login']")}


        // Landsacpe:
//        usernameField -> 380, 270
//        passwordField -> 380, 300
//        submitButton -> 440, 330

        // Portrait:
//        usernameField  {(380, 660)}
//        380, 660
//        380, 730
//        440, 780

    }
}
