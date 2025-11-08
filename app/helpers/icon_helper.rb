module IconHelper
  # Renders an SVG icon from a navigation item
  # @param item [Hash] Navigation item from UiConfig with :svg key
  # @param css_class [String] CSS classes for the SVG element
  # @return [String] HTML-safe SVG element
  def render_nav_icon(item, css_class: "w-5 h-5")
    return "" unless item[:svg]

    content_tag(:svg, class: css_class, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
      item[:svg].html_safe
    end
  end

  # Renders an icon from the ICONS hash by name
  # @param name [String] Icon name from UiConfig::ICONS
  # @param css_class [String] CSS classes for the SVG element
  # @return [String] HTML-safe SVG element
  def render_icon(name, css_class: "w-5 h-5")
    svg_path = UiConfig::ICONS[name]
    return "" unless svg_path

    content_tag(:svg, class: css_class, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
      svg_path.html_safe
    end
  end

  # Renders a PRO badge if the condition is met
  # @param badge [Hash] Badge configuration with :text and :show_when keys
  # @param user [User] Current user object
  # @return [String] HTML-safe badge element or empty string
  def render_badge(badge, user)
    return "" unless badge && badge[:show_when]&.call(user)

    content_tag(:span, class: "badge-pro") do
      badge[:text]
    end
  end
end
