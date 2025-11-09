module ApplicationHelper
  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : "Tiago Antunes - AI-Driven Software Engineer"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : "Building intelligent web solutions with Ruby on Rails and modern AI frameworks. Specializing in LLMs, RAG systems, and AI-powered automation."
  end

  def meta_image
    content_for?(:meta_image) ? content_for(:meta_image) : nil
  end

  def meta_url
    content_for?(:meta_url) ? content_for(:meta_url) : request.original_url
  end
end
