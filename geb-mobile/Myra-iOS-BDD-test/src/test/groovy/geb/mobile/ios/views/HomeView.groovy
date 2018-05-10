package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView

class HomeView extends IosBaseView {

    static content = {

        syncButton {$("#SyncButton")}
        createButton {$("#CreateRupButton")}

//        TODO: add ID
        syncStatusField {$("#SyncTimeStamp")}

        emptyTable {$("//XCUIElementTypeTable[@name=\"Empty list\"]")}
        rangeTable {$("#XCUIElementTypeTable")}
        rangeTableCells {$("#XCUIElementTypeCell")}
        completedTableCells {$("//XCUIElementTypeStaticText[@name=\"Completed\"]")}

        viewEditButtons {$("#EditOrViewButton")}
    }
}
