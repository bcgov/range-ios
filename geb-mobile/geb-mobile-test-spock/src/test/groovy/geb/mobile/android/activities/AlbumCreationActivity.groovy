package geb.mobile.android.activities

import geb.mobile.android.AndroidBaseActivity
import groovy.util.logging.Slf4j

@Slf4j
class AlbumCreationActivity extends AndroidBaseActivity {
//    ca.bc.gov.secureimage.screens.createalbum.CreateAlbumActivity

    static content = {

        backButton { $("#ca.bc.gov.secureimage:id/backIv") }

        deleteButton { $("#ca.bc.gov.secureimage:id/deleteAlbumIv") }

        confirmDeleteButton {$("#ca.bc.gov.secureimage:id/deleteTv")}

        viewAllImagesButton {$("#ca.bc.gov.secureimage:id/viewAllImagesTv")}

        addImageButton {$("#ca.bc.gov.secureimage:id/addImagesLayout")}

        uploadButton {$("#ca.bc.gov.secureimage:id/uploadTv")}


    }



}
