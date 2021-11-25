import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard"
export default class extends Controller {
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      console.log("200 mili passed ...")
      this.element.submit()
      // Rails.fire(this.formTarget, 'submit')
    }, 200)
  }
}
