import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard"
export default class extends Controller {
  static targets = [ "form" ]
  
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      console.log("200 mili passed ...")
      this.formTarget.requestSubmit()
      // Rails.fire(this.formTarget, 'submit')
    }, 200)
  }
}
