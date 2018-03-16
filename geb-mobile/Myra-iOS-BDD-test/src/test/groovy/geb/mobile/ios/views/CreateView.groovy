package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView


class CreateView extends IosBaseView {

     static content = {

//         Title section:
         cancelButton = {$("//XCUIElementTypeButton[@name=\"Save to Drafts\"]")}

//         Create-new buttons:
         addAgreementHolderButton = {$("//XCUIElementTypeButton[@name=\"+ Add Agreement Holder\"]")}
         addYear1Button = {$("//XCUIElementTypeButton[@name=\"+ Add Year\"][1]")}
         addYear2Button = {$("//XCUIElementTypeButton[@name=\"+ Add Year\"]")}
         addLiveStockButton = {$("//XCUIElementTypeButton[@name=\"+ Add LiveStock\"]")}
         addPastureButton = {$("//XCUIElementTypeButton[@name=\"+ Add Pasture\"]")}


//         Auto-fill fields, (need accessibility id):
//         rangeNumberField = {$("")}



//         Side bar elements:
         submitButton = {$("//XCUIElementTypeStaticText[@name=\"Review and Submit\"]")}


     }
}
