package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView

class HomeView extends IosBaseView {

    static content = {

        createButton {$("//XCUIElementTypeButton[@name=\" + Create New RUP \"]")}
        rangeTable {$("#XCUIElementTypeTable")}
        rangeTableCells {$("#XCUIElementTypeCell")}
        completedTableCells {$("//XCUIElementTypeStaticText[@name=\"Completed\"]")}


    }
}
