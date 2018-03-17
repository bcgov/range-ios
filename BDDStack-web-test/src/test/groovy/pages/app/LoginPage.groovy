package pages.app

import geb.Page

class LoginPage extends Page {
    static at = { title == "My Range App" }
    static url = "login"
}
