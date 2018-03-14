package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

@Slf4j
class AccessPermissionActivity extends AndroidBaseActivity {
    static content = {
        allowAccessButton {$("#com.android.packageinstaller:id/permission_allow_button")}
    }
}
