package geb.mobile.ios.views.CreateRUP

import geb.mobile.ios.IosBaseView


class CreateView extends IosBaseView {

     static content = {

//         Create-new buttons:
         addYearButton {$("#AddYearlyScheduleButton")}
         addPastureButton {$("#AddPastureButton")}


//         Auto-fill fields, (need accessibility id):

//         Title section:
         cancelButton {$("#SaveDraftButton")}

//         Side bar elements:
         submitButton {$("#SubmitRUPButton")}
         BasicInformationSectionButton {$("#BasicInformationSectionButton")}
         PastureSectionButton {$("#PastureSectionButton")}
         ScheduleSectionButton {$("#ScheduleSectionButton")}


//         Yearly schedule:
         grazingScheduleList {$("#YearlyScheduleCellName")}
         scheduleOptionButton {$("#ScheduleCellOpenMenu")}
     }
}
