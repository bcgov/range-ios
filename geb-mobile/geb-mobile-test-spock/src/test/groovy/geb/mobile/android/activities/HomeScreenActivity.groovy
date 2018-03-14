package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j


@Slf4j
class HomeScreenActivity extends AndroidBaseActivity {

    static content = {

        createAlbumButton {$("#ca.bc.gov.secureimage:id/createAlbumTv")}

        albums {$("#ca.bc.gov.secureimage:id/layout")}

    }
}
