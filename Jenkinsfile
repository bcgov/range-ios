import groovy.json.JsonOutput

// FRABRIC_APIKEY
// FRABRIC_TOKEN

def APP_NAME = 'range-myra-ios'
def TAG_NAMES = ['dev', 'test', 'prod']
def CMD_PREFIX = 'PATH=$PATH:$PWD/node-v9.6.1-linux-x64/bin'
def NODE_URI = 'https://nodejs.org/dist/v9.7.0/node-v9.7.0-linux-x64.tar.xz'
def PIRATE_ICO = 'http://icons.iconarchive.com/icons/aha-soft/torrent/64/pirate-icon.png'
def JENKINS_ICO = 'https://wiki.jenkins-ci.org/download/attachments/2916393/logo.png'
def OPENSHIFT_ICO = 'https://commons.wikimedia.org/wiki/File:OpenShift-LogoType.svg'



def XCODE_WORKSPACE = 'Myra.xcworkspace' // Path to the xcodeproj/xcodeworkspace
def XCODE_SCHEME = 'Pods-Myra'
// def xcarchive_name = "Jenkins iOS Example.xcarchive" // Name of the archive to build
// def build_scheme = 'Jenkins iOS Example' // Scheme to build the app
// def test_scheme = 'Jenkins iOS Example' // Scheme to build tests
// def simulator_device = 'iPhone 7' // Name of the device type to use for tests

// def notifySlack(text, channel, url, attachments, icon) {
//     def slackURL = url
//     def jenkinsIcon = icon
//     def payload = JsonOutput.toJson([text: text,
//         channel: channel,
//         username: "Jenkins",
//         icon_url: jenkinsIcon,
//         attachments: attachments
//     ])
//     sh "curl -s -S -X POST --data-urlencode \'payload=${payload}\' ${slackURL}"
// }

// Configure Jenkins to keep the last 200 build results and the last 50 build artifacts for this job
// properties([buildDiscarder(logRotator(artifactNumToKeepStr: '50', numToKeepStr: '200'))])

node ('xcode') {
  stage('Checkout') {
    echo "Checking out source"
    checkout scm
  }

  stage('build') {
    echo "Build Xcode project"
    //using the preset provision profile

// Set as env var:
    // echo "${FRABRIC_APIKEY}"

// Get from script:
    FRABRIC_APIKEY = sh (
      script: 'oc get secret/fabric -o template --template="{{.data.apiKey}}" | base64 --decode',
      returnStdout: true
        ).trim()
    echo "FRABRIC_APIKEY: ${FRABRIC_APIKEY}"

    FRABRIC_TOKEN = sh (
      script: 'oc get secret/fabric -o template --template="{{.data.token}}" | base64 --decode',
      returnStdout: true
        ).trim()
    echo "FRABRIC_TOKEN: ${FRABRIC_TOKEN}"

    // sh "pod install"
    //xcode build on simulator / multiple simulators
    // sh "xcrun xcodebuild -scheme '${build_scheme}' -destination 'name=iPhone 7' clean build | tee build/xcodebuild.log | xcpretty"
    // "xcodebuild -workspace '${XCODE_WORKSPACE}' -scheme '${XCODE_SCHEME}' -sdk '*targetSDK*' -configuration *buildConfig* CODE_SIGN_IDENTITY='*NameOfCertificateIdentity* PROVISIONING_PROFILE='*ProvisioningProfileName' OTHER_CODE_SIGN_FLAGS='--keychain *keyChainName*'"
  }

  // stage('Test') {
  //   echo "Testing: ${BUILD_ID}"
  //   echo "BDD Funtional Testing"
  //   dir('BDDStack-web-test') {
  //     try {
  //       sh './gradlew --debug --stacktrace chromeHeadlessTest'
  //     } finally { 
  //       archiveArtifacts allowEmptyArchive: true, artifacts: 'build/reports/**/*'
  //       archiveArtifacts allowEmptyArchive: true, artifacts: 'build/test-results/**/*'
  //     }
  //   }
  // }
 
}
