package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

@Slf4j
class RedirectActivity extends AndroidBaseActivity {

    static content = {

        loginButton { $("#ca.bc.gov.secureimage:id/loginTv") }
    }


}
