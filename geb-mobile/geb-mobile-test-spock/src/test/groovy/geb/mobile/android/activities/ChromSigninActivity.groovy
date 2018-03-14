package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

@Slf4j
class ChromSigninActivity extends AndroidBaseActivity {

    static content = {


        loginButton {$("*kc-login")}


//        currentActivityName {
//            getCurrentActivity()
//        }
//
//        currentURL {
//            getPageUrl()
//        }
    }

}
