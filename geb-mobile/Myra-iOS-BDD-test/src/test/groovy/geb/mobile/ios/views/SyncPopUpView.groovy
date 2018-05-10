package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView

class SyncPopUpView extends IosBaseView {

    static content = {

//        closePopUpButton {$("//XCUIElementTypeButton[@name=\"Close\"]")}
//        successMsg {$("//XCUIElementTypeStaticText[@name=\"Sync completed.\"]")}
//        failureMsg {$("//XCUIElementTypeStaticText[@name=\"Sync failed\"]")}


//        SHelly note what's this?
        closePopUpButton {$("#Close")}
        successMsg {$("//XCUIElementTypeStaticText[@name=\"Sync completed.\"]")}
        failureMsg {$("//XCUIElementTypeStaticText[@name=\"Sync failed\"]")}


    }
}
