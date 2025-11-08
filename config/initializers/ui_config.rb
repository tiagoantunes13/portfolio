# app/config/ui_config.rb or config/initializers/ui_config.rb

module UiConfig
  # Navigation items for authenticated users
  MAIN_NAV = [
    {
      name: "Applications",
      path: :root_path,
      icon: "document",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>'
    },
    {
      name: "Search Jobs",
      path: :root_path,
      icon: "search",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>'
    },
    {
      name: "Saved Jobs",
      path: :account_path,
      icon: "bookmark",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"></path>'
    },
    {
      name: "AI Chat",
      path: :account_path,
      icon: "chat",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"></path>',
      badge: { text: "PRO", show_when: ->(user) { !user.pro? } }
    }
  ].freeze

  # Tools dropdown items (feature-specific)
  TOOLS_NAV = [
    {
      name: "Check Location",
      path: :account_path,
      icon: "map-pin",
      description: "Analyze job locations",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>'
    },
    {
      name: "Import CV",
      path: :account_path,
      icon: "upload",
      description: "Upload your resume",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>'
    }
  ].freeze

  # User menu items
  USER_MENU = [
    {
      name: "Profile",
      path: :root_path,
      icon: "user",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>'
    },
    {
      name: "Account",
      path: :account_path,
      icon: "settings",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>'
    },
    { type: :divider },
    {
      name: "Logout",
      path: :destroy_user_session_path,
      icon: "logout",
      method: :delete,
      variant: "danger",
      svg: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>'
    }
  ].freeze

  # Tools dropdown configuration
  TOOLS_DROPDOWN = {
    label: "Tools",
    icon: "cog"
  }.freeze

  # Additional icons used in UI
  ICONS = {
    "cog" => '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>',
    "chevron-down" => '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>',
    "menu" => '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />'
  }.freeze

  # Landing page navigation (public)
  LANDING_NAV = [
    { name: "Features", path: :root_path },
    { name: "Pricing", path: :pricing_path },
    # { name: "About", path: :about_path },
    { name: "Contact", path: :contact_path },
    { name: "Sign In", path: :new_user_session_path, button_style: true }
  ].freeze

  # Footer links
  FOOTER_LINKS = [
    { name: "Privacy Policy", path: :privacy_path },
    { name: "Terms of Service", path: :terms_path },
    { name: "Contact Us", path: :contact_path }
  ].freeze

  # Brand configuration
  BRAND = {
    name: "ApplyTrack",
    logo_path: "/logo.svg",
    logo_alt: "ApplyTrack Logo"
  }.freeze

  # Social links
  # SOCIAL_LINKS = [
  #   { name: "Twitter", url: "https://twitter.com/yoursaas", icon: "twitter" },
  #   { name: "GitHub", url: "https://github.com/yoursaas", icon: "github" }
  # ].freeze
end
