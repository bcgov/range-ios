package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

class SettingsActivity extends AndroidBaseActivity {

    static content = {

        lockTab {$("//android.widget.TextView[@text='Lock screen and security']")}
        lockType {$("//android.widget.TextView[@text='Screen lock type']")}
        pinOptions {$("#com.android.settings:id/lock_pin")}
        pinField {$("#com.android.settings:id/password_entry")}
        nextButton {$("#com.android.settings:id/next_button")}


        switchToAPP {
            switch2App()
        }

    }

}