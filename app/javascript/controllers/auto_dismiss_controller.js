import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss();
    }, 5000); // Auto-dismiss after 5 seconds
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  dismiss() {
    this.element.style.transition =
      "opacity 300ms ease-out, transform 300ms ease-out";
    this.element.style.opacity = "0";
    this.element.style.transform = "translateX(100px)";

    setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}
