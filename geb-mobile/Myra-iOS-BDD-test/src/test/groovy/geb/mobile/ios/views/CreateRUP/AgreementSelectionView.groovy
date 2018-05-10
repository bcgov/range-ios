package geb.mobile.ios.views.CreateRUP

import geb.mobile.ios.IosBaseView


class AgreementSelectionView extends IosBaseView {

    static content = {

//        cancelButton {$("//XCUIElementTypeButton[@name=\"Cancel\"]")}
//        agreementList { $("//XCUIElementTypeStaticText[@name=\"RAN123674\"]") }


        cancelButton {$("#SelectAgreementCancelButton")}
        agreementList { $("#AgreementRangeNumber") }
        selectButtons {$("#Select")}
    }
}