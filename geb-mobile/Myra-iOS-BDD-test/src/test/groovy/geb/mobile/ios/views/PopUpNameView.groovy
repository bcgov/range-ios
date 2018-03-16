package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView


class PopUpNameView extends IosBaseView {

    static content = {


        cancelButton = {$("//XCUIElementTypeButton[@name=\"Cancel\"]")}
        addButton = {$("//XCUIElementTypeButton[@name=\"Add\"]")}
//        the text input field
//        verify the title of window


    }
}
