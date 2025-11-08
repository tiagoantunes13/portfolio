import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    fallbackUrl: String,
  };

  navigate(event) {
    event.preventDefault();

    // Check if there's history to go back to
    if (window.history.length > 1) {
      window.history.back();
    } else {
      // Fallback to the provided URL
      window.location.href = this.fallbackUrlValue;
    }
  }
}

// How to use

// <%= link_to "#",
//     data: {
//       controller: "back-button",
//       action: "click->back-button#navigate",
//       back_button_fallback_url_value: request.referer || jobs_path
//     },
//     class: "inline-flex items-center text-sm text-gray-600 hover:text-indigo-600 transition-colors" do %>
//   <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
//     <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
//   </svg>
//   Back
// <% end %>
