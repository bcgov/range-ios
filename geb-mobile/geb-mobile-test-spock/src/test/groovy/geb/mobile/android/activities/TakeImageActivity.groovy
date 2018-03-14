package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

@Slf4j
class TakeImageActivity extends AndroidBaseActivity {

    static content = {

        shutterButton {$("#ca.bc.gov.secureimage:id/captureImageIv")}

        flashButton {$("#ca.bc.gov.secureimage:id/flashControlTv")}

        backButton {$("#ca.bc.gov.secureimage:id/backIv")}

        imageCountText {$("#ca.bc.gov.secureimage:id/imageCounterTv")}
    }

}
