package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView


class AgreementSelectionView extends IosBaseView {

    static content = {

        cancelButton {$("//XCUIElementTypeButton[@name=\"Cancel\"]")}
        firstAgreement { $("//XCUIElementTypeStaticText[@name=\"RAN123674\"]") }
    }
}