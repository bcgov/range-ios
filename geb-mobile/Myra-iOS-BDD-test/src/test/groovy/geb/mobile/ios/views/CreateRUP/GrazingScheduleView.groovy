package geb.mobile.ios.views.CreateRUP

import geb.mobile.ios.IosBaseView

class GrazingScheduleView extends IosBaseView {

    static content = {

        addRowButton {$("#AddLiveScheduleElementButton")}
        authAUM {$("#SchedulePageAuthAUMLabel")}
        totalAUM {$("#SchedulePageTotalAUMLabel")}



    }
}