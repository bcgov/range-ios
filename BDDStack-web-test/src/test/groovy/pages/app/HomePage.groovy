package pages.app

import geb.Page

class HomePage extends Page {
    static at = { title == "My Range App" }
    static url = "range-use-plans"
}
