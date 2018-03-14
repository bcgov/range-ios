package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

class FirstTimeLoginActivity extends AndroidBaseActivity {

    static content = {

        authenticateButton {$("//android.widget.TextView[@text='AUTHENTICATE']")}

        passwordField {$("#com.android.settings:id/password_entry")}

        nextButton {$("#com.android.settings:id/next_button")}

        switchApp {
            switch2Settings()
        }

    }
}
