package geb.mobile.ios.views

import geb.mobile.ios.IosBaseView

/**
 * Created by gmueksch on 01.09.14.
 */
class HomeView extends IosBaseView {

    static content = {

        createButton {$("//XCUIElementTypeButton[@name=\" + Create New RUP \"]")}
        rangeTable {$("#XCUIElementTypeTable")}
        rangeTableCells {$("#XCUIElementTypeCell")}
        completedTableCells {$("//XCUIElementTypeStaticText[@name=\"Completed\"]")}


    }
}
