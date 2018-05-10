package geb.mobile.ios.views.CreateRUP

import geb.mobile.ios.IosBaseView

class PickerPopUpView extends IosBaseView {

    static content = {

        pickerRows {$("#XCUIElementTypePickerWheel")}
//        selectButton {$("//XCUIElementTypeButton[@name=\"Select\"]")}
        selectButton {$("#Select")}

    }
}
