package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

@Slf4j
class CameraActivity extends AndroidBaseActivity {

    static content = {
        shutterButton {find("#shutter_button")}
        preview {find("#preview_frame")}
        acceptButton {$("#android:id/button1")}
    }

}
