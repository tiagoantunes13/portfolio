# Rails SaaS Skeleton - Claude Context Guide

This is a comprehensive reference for building features in this Rails 8 SaaS skeleton app. When adding new functionality, **always follow The Rails Way** and leverage existing patterns.

---

## ⭐ The Rails Way Philosophy

This skeleton strictly follows Rails conventions and best practices. **This is non-negotiable.**

### Core Principles

✅ **DO:**
- Server-side rendering first (Hotwire/Turbo for interactivity)
- Follow Rails conventions (RESTful routes, MVC, concerns, etc.)
- Use Turbo Frames and Turbo Streams for dynamic updates
- Minimal JavaScript (Stimulus controllers for UI sprinkles only)
- Use Rails 8 features (Solid Queue, Solid Cache, Solid Cable)
- Leverage existing patterns (see sections below)
- Update config files (PricingConfig, UiConfig) instead of hardcoding

❌ **DON'T:**
- Use React, Vue, or heavy JavaScript frameworks
- Build JSON APIs unless absolutely necessary
- Bypass Rails conventions or "do it the JavaScript way"
- Rebuild authentication, payments, or core infrastructure
- Hardcode pricing, features, or navigation in views
- Use Sidekiq/Redis when Solid Queue/Cache works

### Rails 8 in This App

We use modern Rails 8 features:
- **Turbo 8** - Frames, Streams, instant page updates
- **Solid Queue** - Background jobs (database-backed, no Redis needed)
- **Solid Cache** - Database caching
- **Solid Cable** - WebSockets for real-time features
- **Hotwire** - Turbo + Stimulus for SPA-like experience
- **Propshaft** - Asset pipeline

### When to Use JavaScript

**Use Stimulus for:**
- Dropdown toggles (see: `auto_dismiss_controller.js`)
- Form field interactions
- Client-side animations
- Copy-to-clipboard buttons
- UI polish

**Use Turbo for:**
- Form submissions (with Turbo Streams for feedback)
- Page updates (Turbo Frames)
- Real-time updates (Turbo Streams)
- Navigation

**Never use JavaScript for:**
- Full page navigation
- Data fetching (use Rails controllers)
- Business logic
- Form validation (do server-side with Rails validations)

---

## 📋 Overview

### What This Skeleton Is

A production-ready Rails 8 SaaS application with:
- User authentication (Devise)
- Subscription payments (Stripe via Pay gem)
- Usage-based feature gating
- AI integration framework (RubyLLM)
- Config-driven architecture
- Modern Tailwind UI components
- Deployment-ready (Kamal)

### Tech Stack

- **Ruby** 3.3.6
- **Rails** 8.0.4
- **Database** PostgreSQL
- **CSS** Tailwind CSS (with @layer components)
- **JavaScript** Hotwire (Turbo + Stimulus)
- **Payments** Stripe (via Pay gem)
- **AI** RubyLLM (OpenAI, Gemini, Ollama support)
- **Jobs** Solid Queue
- **Cache** Solid Cache + Redis
- **Deployment** Kamal with Thruster

---

## 🏗️ Foundation (Already Built - Don't Rebuild)

These core features are configured and ready to use. **Do not rebuild or replace them.**

### Authentication (Devise)

**What's Configured:**
- User registration and login
- Password reset
- Email confirmation (confirmable)
- Session tracking (trackable)
- Remember me

**Usage:**
```ruby
# In controllers
before_action :authenticate_user!
current_user.email
user_signed_in?

# In views
<% if user_signed_in? %>
  <%= current_user.email %>
<% end %>
```

**Customization Points:**
- Views: `app/views/devise/`
- User model: `app/models/user.rb`

**Documentation:** https://github.com/heartcombo/devise

### Payments (Stripe + Pay gem)

**What's Configured:**
- Stripe integration via Pay gem
- Subscription management
- Checkout flow (`CheckoutsController`)
- Billing portal (`BillingPortalController`)
- Webhook handling

**User Model Methods:**
```ruby
current_user.subscribed?          # Has active subscription?
current_user.subscription         # Pay::Subscription object
current_user.free?                # Free plan?
current_user.pro?                 # Pro plan?
current_user.payment_processor    # Stripe customer
```

**Creating Checkout Session:**
```ruby
# In controller
def create
  checkout_session = current_user.payment_processor.checkout(
    mode: "subscription",
    line_items: [{
      price: price_id,
      quantity: 1
    }],
    success_url: success_url,
    cancel_url: cancel_url
  )
  redirect_to checkout_session.url
end
```

**Documentation:**
- Pay gem: https://github.com/pay-rails/pay
- Stripe: https://docs.stripe.com/api

### Background Jobs (Solid Queue)

**What's Configured:**
- Solid Queue (database-backed, no Redis dependency for jobs)
- Async job processing

**Usage:**
```ruby
# Create a job
class MyJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    # Do work
  end
end

# Enqueue
MyJob.perform_later(current_user.id)
```

**Documentation:** https://github.com/basecamp/solid_queue

### Caching (Solid Cache + Redis)

**What's Configured:**
- Solid Cache for database caching
- Redis for additional caching

**Usage:**
```ruby
Rails.cache.fetch("user-#{user.id}-stats", expires_in: 1.hour) do
  # Expensive calculation
end
```

### Deployment (Kamal)

**What's Configured:**
- Kamal deployment scripts
- Thruster for HTTP/2
- Environment configuration

**Documentation:** https://kamal-deploy.org/ AND https://kamal-deploy.org/docs

---

## 🎯 Config-Driven Architecture (CRITICAL PATTERN)

This skeleton uses a **configuration-driven approach**. Business logic (pricing, features, navigation) lives in config files, not scattered across views and controllers.

### Why Config-Driven?

✅ Single source of truth
✅ Easy to update pricing/features
✅ No hardcoded values in views
✅ Consistent across the app

### PricingConfig System

**Location:** `config/initializers/pricing_config.rb`

This file defines ALL pricing tiers, features, limits, and Stripe price IDs.

**Structure:**
```ruby
module PricingConfig
  # Feature keys (used for usage tracking)
  FEATURE_KEYS = {
    ai_cover_letter: "ai_cover_letter",
    location_check: "location_check",
    cv_import: "cv_import",
    # Add new features here
  }

  # Plans with features and limits
  PLANS = {
    free: {
      display_name: "Free Plan",
      price: { display: "$0", interval: "forever" },
      features: {
        ai_cover_letter: { limit: 3, display: "3 AI cover letters" },
        location_check: { limit: 5, display: "5 location checks" },
        # ...
      }
    },
    monthly: {
      display_name: "Pro Monthly",
      stripe_price_id: "price_xxx",
      price: { display: "$9", interval: "month" },
      features: {
        ai_cover_letter: { limit: :unlimited, display: "Unlimited AI cover letters" },
        # ...
      }
    },
    # ...
  }
end
```

**Helper Methods:**
```ruby
# Get feature limit for a plan
PricingConfig.feature_limit(:free, :ai_cover_letter)  # => 3
PricingConfig.feature_limit(:monthly, :ai_cover_letter)  # => :unlimited

# Get feature list for display
PricingConfig.feature_list(:monthly)  # => ["Unlimited AI cover letters", ...]

# Get plan details
PricingConfig::PLANS[:monthly][:stripe_price_id]  # => "price_xxx"
```

**Adding a New Feature with Limits:**

1. Add to `FEATURE_KEYS`:
```ruby
FEATURE_KEYS = {
  # ...
  document_analysis: "document_analysis"
}
```

2. Add to each plan in `PLANS`:
```ruby
free: {
  features: {
    # ...
    document_analysis: { limit: 2, display: "2 document analyses" }
  }
},
monthly: {
  features: {
    # ...
    document_analysis: { limit: :unlimited, display: "Unlimited document analyses" }
  }
}
```

3. Add enum to `UsageEvent` model:
```ruby
enum :event_type, {
  # ...
  document_analysis: 5
}
```

4. Use in your code (see Usage Tracking section below)

### UiConfig System

**Location:** `config/initializers/ui_config.rb`

This file defines ALL navigation menus, icons, and UI structure.

**Structure:**
```ruby
module UiConfig
  # Brand settings
  BRAND = {
    name: "ApplyTrack",
    logo_path: "logo.png",
    logo_alt: "ApplyTrack Logo"
  }

  # Main navigation (dashboard)
  MAIN_NAV = [
    {
      name: "Dashboard",
      path: :root_path,
      icon: "home",
      svg: "<path d='...'/>"
    },
    # ...
  ]

  # Tools dropdown
  TOOLS_NAV = [
    {
      name: "AI Chat",
      path: :chat_path,
      description: "Talk to AI assistant",
      svg: "<path d='...'/>"
    },
    # ...
  ]

  # Icons (SVG paths)
  ICONS = {
    "home" => "<path d='...'/>",
    "menu" => "<path d='...'/>",
    # ...
  }
end
```

**Adding a Navigation Item:**

1. Add to appropriate array in `ui_config.rb`:
```ruby
MAIN_NAV = [
  # ...
  {
    name: "Documents",
    path: :documents_path,
    svg: "<path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'/>"
  }
]
```

2. Navigation automatically appears (no view changes needed)

**Helper Methods:**
```ruby
# In views (already available)
render_nav_icon(item)          # Renders SVG icon
render_icon("menu")            # Renders icon by name
render_badge(badge, user)      # Renders PRO badge if needed
```

---

## 🔐 Feature Patterns (Use These)

### Usage Tracking & Feature Gating

This is the **core pattern** for metered features.

**How It Works:**
1. User tries to use a feature
2. Check if they have credits: `current_user.can_use?(:feature_name)`
3. If yes, do the work and track: `current_user.track_usage(:feature_name)`
4. Limits are defined in `PricingConfig`

**Models:**
- `UsageEvent` - Stores each usage event
- `User` (with `TrackableUsage` concern) - Provides usage methods

**TrackableUsage Methods:**
```ruby
# Check if user can use a feature
current_user.can_use?(:ai_cover_letter)  # => true/false

# Track usage (decrements remaining credits)
current_user.track_usage(:ai_cover_letter, metadata: { job_id: 123 })

# Get limit for user's plan
current_user.limit_for(:ai_cover_letter)  # => 3 or :unlimited

# Get remaining usage
current_user.remaining_usage(:ai_cover_letter)  # => 2

# Get usage this month
current_user.usage_count(:ai_cover_letter)  # => 1
```

**Complete Example - Adding a Document Analysis Feature:**

1. **Update PricingConfig** (see above)

2. **Add UsageEvent enum:**
```ruby
# app/models/usage_event.rb
enum :event_type, {
  ai_cover_letter: 0,
  location_check: 1,
  cv_import: 2,
  # Add new feature
  document_analysis: 5
}
```

3. **Controller logic:**
```ruby
class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def analyze
    @document = current_user.documents.find(params[:id])

    # Check if user can use this feature
    unless current_user.can_use?(:document_analysis)
      flash[:alert] = "You've reached your document analysis limit. Upgrade to Pro for unlimited access."
      redirect_to pricing_path and return
    end

    # Do the work
    result = AnalyzeDocumentService.call(@document)

    # Track usage
    current_user.track_usage(:document_analysis, metadata: { document_id: @document.id })

    # Respond (The Rails Way - use Turbo Stream or redirect)
    respond_to do |format|
      format.html { redirect_to @document, notice: "Analysis complete!" }
      format.turbo_stream  # For real-time updates
    end
  end
end
```

4. **View (show remaining credits):**
```erb
<div class="card">
  <h3>Document Analysis</h3>
  <p>
    Remaining this month:
    <strong><%= current_user.remaining_usage(:document_analysis) %></strong>
    / <%= current_user.limit_for(:document_analysis) %>
  </p>

  <%= button_to "Analyze Document", analyze_document_path(@document),
      method: :post,
      class: "btn-primary",
      disabled: !current_user.can_use?(:document_analysis) %>
</div>
```

### AI Tool Framework (RubyLLM)

This skeleton has a complete framework for building AI-powered features.

**Documentation:** https://github.com/crmne/ruby_llm AND https://rubyllm.com/

**How RubyLLM Works in This App:**

RubyLLM provides:
- Multi-provider support (OpenAI, Gemini, Ollama)
- Tool calling (function calling)
- Schema validation
- Chat history management

**Configuration:**
```ruby
# config/initializers/ruby_llm.rb
RubyLLM.setup do |config|
  config.openai_api_key = Rails.application.credentials.dig(:openai, :api_key)
  config.gemini_api_key = Rails.application.credentials.dig(:gemini, :api_key)
end
```

**Base Tool Classes:**

**Location:** `app/ai/tools/`

1. **BaseTool** - Standard tool with success/error responses
```ruby
# app/ai/tools/base_tool.rb
class BaseTool
  def success_response(data)
    { success: true, data: data }
  end

  def error_response(message)
    { success: false, error: message }
  end
end
```

2. **BaseActionTool** - Adds feature gating for metered features
```ruby
# app/ai/tools/base_action_tool.rb
class BaseActionTool < BaseTool
  def with_feature_gate(user, feature_key)
    unless user.can_use?(feature_key)
      return error_response("Usage limit reached for #{feature_key}")
    end

    result = yield

    if result[:success]
      user.track_usage(feature_key)
    end

    result
  end
end
```

**Creating a New AI Tool:**

Example: Document summarization tool

```ruby
# app/ai/tools/summarize_document_tool.rb
class SummarizeDocumentTool < BaseActionTool
  def self.name
    "summarize_document"
  end

  def self.description
    "Summarizes a document using AI"
  end

  def self.params
    {
      type: "object",
      properties: {
        document_id: {
          type: "integer",
          description: "The ID of the document to summarize"
        }
      },
      required: ["document_id"]
    }
  end

  def execute(params, user:)
    with_feature_gate(user, :document_analysis) do
      document = user.documents.find_by(id: params[:document_id])

      unless document
        return error_response("Document not found")
      end

      # Call AI
      prompt = "Summarize this document: #{document.content}"
      response = ai_chat(prompt)

      success_response({
        document_id: document.id,
        summary: response
      })
    end
  end

  private

  def ai_chat(prompt)
    # Use helper from AiHelper
    AiHelper.ai_chat(prompt)
  end
end
```

**AI Helper Methods:**

**Location:** `app/helpers/ai_helper.rb`

```ruby
# Simple chat
ai_chat("What is Ruby on Rails?")

# Environment-aware (GPT in prod, Ollama in dev)
ai_chat("Summarize this text")

# With tools
ai_chat_for_tools("Help me analyze this document", tools: [SummarizeDocumentTool])

# Fast/cheap model
ai_chat_fast("Quick question")

# Smart/expensive model
ai_chat_smart("Complex reasoning task")
```

**Schema Support:**

Use schemas for structured AI outputs:

```ruby
# app/ai/schemas/document_summary_schema.rb
class DocumentSummarySchema
  def self.schema
    {
      type: "object",
      properties: {
        summary: { type: "string" },
        key_points: { type: "array", items: { type: "string" } },
        sentiment: { type: "string", enum: ["positive", "negative", "neutral"] }
      },
      required: ["summary", "key_points", "sentiment"]
    }
  end
end

# Use in tool
response = RubyLLM::Chat.new(
  provider: :openai,
  model: "gpt-4",
  messages: [{ role: "user", content: prompt }],
  response_format: DocumentSummarySchema.schema
).chat
```

**Complete AI Feature Example:**

```ruby
# 1. Controller
class DocumentsController < ApplicationController
  def summarize
    @document = current_user.documents.find(params[:id])

    # Use the AI tool
    result = SummarizeDocumentTool.new.execute(
      { document_id: @document.id },
      user: current_user
    )

    if result[:success]
      @summary = result[:data][:summary]

      # The Rails Way - use Turbo Stream for update
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @document, notice: "Summary generated!" }
      end
    else
      redirect_to @document, alert: result[:error]
    end
  end
end

# 2. Turbo Stream view (app/views/documents/summarize.turbo_stream.erb)
<%= turbo_stream.update "document-summary" do %>
  <div class="card">
    <h3>AI Summary</h3>
    <p><%= @summary %></p>
  </div>
<% end %>

# 3. View (app/views/documents/show.html.erb)
<div id="document-summary">
  <!-- Summary will appear here -->
</div>

<%= button_to "Generate Summary",
    summarize_document_path(@document),
    method: :post,
    class: "btn-primary",
    disabled: !current_user.can_use?(:document_analysis) %>
```

---

## 🎨 Rails 8 Patterns

### Turbo Frames (Partial Page Updates)

Use Turbo Frames to update parts of a page without full reload.

**Example:**
```erb
<%# app/views/documents/show.html.erb %>
<%= turbo_frame_tag "document-content" do %>
  <div class="card">
    <%= @document.content %>
  </div>
<% end %>

<%= link_to "Edit", edit_document_path(@document),
    data: { turbo_frame: "document-content" } %>

<%# app/views/documents/edit.html.erb %>
<%= turbo_frame_tag "document-content" do %>
  <%= form_with model: @document do |f| %>
    <%= f.text_area :content, class: "input-dark" %>
    <%= f.submit "Save", class: "btn-primary" %>
  <% end %>
<% end %>
```

Form submission stays within frame, no full page reload.

### Turbo Streams (Real-time Updates)

Use Turbo Streams to push updates to specific DOM elements.

**Example:**
```ruby
# Controller
def create
  @comment = @document.comments.build(comment_params)

  if @comment.save
    respond_to do |format|
      format.turbo_stream  # Renders create.turbo_stream.erb
      format.html { redirect_to @document }
    end
  end
end

# app/views/comments/create.turbo_stream.erb
<%= turbo_stream.prepend "comments" do %>
  <%= render @comment %>
<% end %>

<%= turbo_stream.update "comment-form" do %>
  <%= render "comments/form", document: @document, comment: Comment.new %>
<% end %>

# View
<div id="comments">
  <%= render @document.comments %>
</div>

<div id="comment-form">
  <%= render "comments/form", document: @document, comment: Comment.new %>
</div>
```

### Stimulus Controllers (Minimal JS)

Use Stimulus for UI interactions only.

**Existing Controllers:**
- `auto_dismiss_controller.js` - Auto-dismiss flash messages
- `back_button_controller.js` - Back button navigation

**Example - Creating a Copy Button Controller:**

```javascript
// app/javascript/controllers/copy_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy() {
    const text = this.sourceTarget.value
    navigator.clipboard.writeText(text)

    // Show feedback
    this.element.innerHTML = "Copied!"
    setTimeout(() => {
      this.element.innerHTML = "Copy"
    }, 2000)
  }
}
```

```erb
<%# Use in view %>
<div data-controller="copy">
  <input type="text" value="<%= @code %>" data-copy-target="source">
  <button data-action="click->copy#copy" class="btn-sm">Copy</button>
</div>
```

### Background Jobs with Solid Queue

```ruby
# Create a job
class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    # Process document
  end
end

# Enqueue
ProcessDocumentJob.perform_later(@document.id)

# In controller
def upload
  @document = current_user.documents.create!(document_params)
  ProcessDocumentJob.perform_later(@document.id)

  redirect_to @document, notice: "Document uploaded. Processing in background..."
end
```

---

## 💅 UI Components (@layer components)

**Location:** `app/assets/tailwind/application.css`

These reusable component classes are already defined. **Use them instead of inline utilities.**

### Buttons

```ruby
.btn-primary    # Large primary CTA (indigo, hover scale)
.btn-secondary  # Large secondary button (gray, border)
.btn-sm         # Small primary button
.btn-ghost      # Ghost/text style button
```

**Usage:**
```erb
<%= link_to "Get Started", signup_path, class: "btn-primary" %>
<%= link_to "Learn More", about_path, class: "btn-secondary" %>
<%= link_to "Sign In", login_path, class: "btn-ghost" %>

<%# Can extend with utilities %>
<%= link_to "Delete", @document, method: :delete, class: "btn-primary !bg-red-600" %>
```

### Form Inputs

```ruby
.input-dark     # Dark theme text input
.textarea-dark  # Dark theme textarea
```

**Usage:**
```erb
<%= f.text_field :name, class: "input-dark", placeholder: "Your name" %>
<%= f.email_field :email, class: "input-dark" %>
<%= f.text_area :content, class: "textarea-dark", rows: 6 %>
```

### Cards

```ruby
.card       # Standard white card with shadow
.card-dark  # Dark theme card
```

**Usage:**
```erb
<div class="card">
  <h3 class="text-xl font-bold">Card Title</h3>
  <p>Card content here</p>
</div>

<%# Can override specific utilities %>
<div class="card border-emerald-200">
  <p>Success message</p>
</div>
```

### Badges

```ruby
.badge-pro      # Gradient PRO badge (indigo to purple)
.badge-success  # Green success/active badge
```

**Usage:**
```erb
<span class="badge-pro">PRO</span>
<span class="badge-success">Active</span>
```

### When to Use Components vs Inline Utilities

**⭐ IMPORTANT: Most of your styling will be inline Tailwind utilities - that's normal and expected!**

Component classes (`.btn-primary`, `.card`, etc.) are for **VERY specific, repeatedly used UI elements only**. Everything else should use inline Tailwind utilities directly in your views.

**Rule of Thumb:**
Only extract to `@layer components` if you're repeating the **EXACT same pattern 3+ times** across different pages/features.

---

**✅ Use component classes for:**
- **Buttons** - Used everywhere, must be consistent (`.btn-primary`, `.btn-secondary`)
- **Form inputs** - Standardized across all forms (`.input-dark`, `.textarea-dark`)
- **Cards** - Common container pattern (`.card`, `.card-dark`)
- **Badges** - Small reusable UI elements (`.badge-pro`, `.badge-success`)

**✅ Use inline Tailwind utilities for (MOST THINGS):**
- **Layouts** - Flexbox, grid, positioning (`flex`, `grid`, `absolute`, `relative`)
- **Spacing** - Margins, padding, gaps (`mt-4`, `px-8`, `gap-6`)
- **Responsive design** - Breakpoint modifiers (`sm:flex-row`, `lg:grid-cols-3`)
- **Page-specific designs** - Hero sections, landing pages, unique layouts
- **Typography** - Text sizes, weights, colors (`text-xl`, `font-bold`, `text-gray-700`)
- **Colors** - Backgrounds, borders, text colors (`bg-indigo-600`, `border-gray-200`)
- **Shadows, borders, effects** - Visual enhancements (`shadow-lg`, `rounded-xl`, `hover:scale-105`)
- **Custom grids and containers** - One-off layouts
- **One-time styling** - Anything that doesn't repeat

---

**Examples:**

**✅ CORRECT - Extract to component (repeats 20+ times):**
```erb
<%# Button used on every page - use component class %>
<%= link_to "Get Started", signup_path, class: "btn-primary" %>
<%= link_to "Learn More", about_path, class: "btn-secondary" %>
```

**✅ CORRECT - Inline utilities (page-specific layout):**
```erb
<%# Hero section only on landing page - write inline %>
<div class="px-10 flex flex-1 justify-center py-5 bg-gradient-to-b from-gray-900 via-gray-800 to-gray-900 min-h-screen">
  <div class="flex flex-col gap-12 px-4 py-24 items-center justify-center text-center">
    <h1 class="text-white text-7xl font-bold leading-tight">Welcome</h1>
    <p class="text-gray-300 text-2xl">Your tagline here</p>
  </div>
</div>
```

**✅ CORRECT - Mix components with inline utilities:**
```erb
<%# Component class for button, inline for layout %>
<div class="flex flex-col sm:flex-row gap-4 items-center mt-8">
  <%= link_to "Get Started", signup_path, class: "btn-primary" %>
  <%= link_to "Learn More", about_path, class: "btn-secondary" %>
</div>
```

**✅ CORRECT - Extend component with utilities:**
```erb
<%# Base component + contextual overrides %>
<div class="card border-emerald-200 mb-6">
  <p>Success message</p>
</div>

<%= link_to "Delete", @document, method: :delete, class: "btn-primary !bg-red-600 hover:!bg-red-700" %>
```

**❌ WRONG - Don't extract one-off designs:**
```ruby
# DON'T create this in application.css:
.hero-section {
  @apply px-10 flex flex-1 justify-center py-5 bg-gradient-to-b from-gray-900 via-gray-800 to-gray-900 min-h-screen;
}

# Just write it inline in the view!
```

**❌ WRONG - Don't extract contextual layouts:**
```ruby
# DON'T create this:
.document-grid {
  @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6;
}

# Just write it inline where you need it:
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
```

---

**Summary:**
- **Default approach:** Write Tailwind utilities inline in your ERB files
- **Only extract:** If the EXACT pattern repeats 3+ times and needs consistency
- **Current components:** Buttons, form inputs, cards, badges (that's it!)
- **Everything else:** Inline utilities

---

## 📚 Key Gems & Documentation

### RubyLLM
**Purpose:** LLM abstraction layer for AI features
**Docs:** https://github.com/crmne/ruby_llm AND https://rubyllm.com/
**Usage:** See "AI Tool Framework" section above

### Devise
**Purpose:** User authentication
**Docs:** https://github.com/heartcombo/devise
**Usage:** See "Authentication" section above

### Pay gem
**Purpose:** Payments and subscriptions
**Docs:** https://github.com/pay-rails/pay
**Usage:** See "Payments" section above

### Hotwire (Turbo + Stimulus)
**Purpose:** SPA-like experience without heavy JavaScript
**Turbo Docs:** https://turbo.hotwired.dev/
**Stimulus Docs:** https://stimulus.hotwired.dev/
**Usage:** See "Rails 8 Patterns" section above

### Tailwind CSS
**Purpose:** Utility-first CSS framework
**Docs:** https://tailwindcss.com/docs
**Usage:** See "UI Components" section above

### Solid Queue
**Purpose:** Database-backed background jobs
**Docs:** https://github.com/basecamp/solid_queue
**Usage:** See "Background Jobs" section above

---

## 🛠️ Common Task Patterns (The Rails Way)

### Adding a Feature with Usage Limits

**Step-by-step:**

1. **Define in PricingConfig:**
```ruby
# config/initializers/pricing_config.rb
FEATURE_KEYS = {
  my_feature: "my_feature"
}

PLANS = {
  free: {
    features: {
      my_feature: { limit: 5, display: "5 uses per month" }
    }
  },
  monthly: {
    features: {
      my_feature: { limit: :unlimited, display: "Unlimited uses" }
    }
  }
}
```

2. **Add to UsageEvent:**
```ruby
# app/models/usage_event.rb
enum :event_type, {
  my_feature: 10  # Pick next available number
}
```

3. **Use in controller:**
```ruby
def my_action
  unless current_user.can_use?(:my_feature)
    redirect_to pricing_path, alert: "Limit reached"
    return
  end

  # Do work
  result = MyService.call(params)

  # Track usage
  current_user.track_usage(:my_feature)

  redirect_to root_path, notice: "Success!"
end
```

### Adding a Navigation Item

**Edit UiConfig:**
```ruby
# config/initializers/ui_config.rb
MAIN_NAV = [
  # Existing items...
  {
    name: "New Feature",
    path: :new_feature_path,
    svg: "<path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 6v6m0 0v6m0-6h6m-6 0H6'/>"
  }
]
```

Navigation automatically updates (no view changes needed).

### Creating an AI-Powered Feature

**Full example:**

```ruby
# 1. Create tool (app/ai/tools/my_ai_tool.rb)
class MyAiTool < BaseActionTool
  def self.name
    "my_ai_feature"
  end

  def self.params
    {
      type: "object",
      properties: {
        input: { type: "string" }
      },
      required: ["input"]
    }
  end

  def execute(params, user:)
    with_feature_gate(user, :my_ai_feature) do
      result = ai_chat("Process this: #{params[:input]}")
      success_response({ result: result })
    end
  end
end

# 2. Controller
class MyFeaturesController < ApplicationController
  def process
    result = MyAiTool.new.execute(
      { input: params[:input] },
      user: current_user
    )

    if result[:success]
      @result = result[:data][:result]
      respond_to do |format|
        format.turbo_stream
      end
    else
      redirect_to root_path, alert: result[:error]
    end
  end
end

# 3. Route
resources :my_features do
  member do
    post :process
  end
end

# 4. View
<%= form_with url: process_my_feature_path(@feature), method: :post do |f| %>
  <%= f.text_area :input, class: "textarea-dark" %>
  <%= f.submit "Process with AI", class: "btn-primary",
      disabled: !current_user.can_use?(:my_ai_feature) %>
<% end %>

<div id="result">
  <!-- Turbo stream will update here -->
</div>
```

### Building Forms (The Rails Way)

**Use form_with (Turbo-enabled by default):**

```erb
<%= form_with model: @document, class: "flex flex-col gap-6" do |f| %>
  <div class="flex flex-col gap-3">
    <%= f.label :title, class: "text-white text-base font-semibold" %>
    <%= f.text_field :title, class: "input-dark" %>
  </div>

  <div class="flex flex-col gap-3">
    <%= f.label :content, class: "text-white text-base font-semibold" %>
    <%= f.text_area :content, class: "textarea-dark", rows: 10 %>
  </div>

  <%= f.submit "Save", class: "btn-primary" %>
<% end %>
```

**With Turbo Stream response:**
```ruby
# Controller
def create
  @document = current_user.documents.build(document_params)

  if @document.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @document }
    end
  else
    render :new, status: :unprocessable_entity
  end
end

# app/views/documents/create.turbo_stream.erb
<%= turbo_stream.prepend "documents" do %>
  <%= render @document %>
<% end %>

<%= turbo_stream.update "flash" do %>
  <div class="card border-emerald-200">Document created!</div>
<% end %>
```

### Adding Real-time Updates

**Use Turbo Streams with broadcasts:**

```ruby
# Model
class Comment < ApplicationRecord
  belongs_to :document

  after_create_commit -> { broadcast_prepend_to document, target: "comments" }
  after_update_commit -> { broadcast_replace_to document }
  after_destroy_commit -> { broadcast_remove_to document }
end

# View
<%= turbo_stream_from @document %>

<div id="comments">
  <%= render @document.comments %>
</div>
```

When a comment is created, it automatically appears for all users viewing that document.

---

## ❌ Anti-Patterns (What NOT to Do)

### Don't Use Heavy JavaScript Frameworks

**❌ Wrong:**
```javascript
// Building a React component for a simple form
import React from 'react'
import { useState } from 'react'

function DocumentForm() {
  const [title, setTitle] = useState('')
  // ... lots of JS state management
}
```

**✅ Right:**
```erb
<%# Simple Rails form with Turbo %>
<%= form_with model: @document do |f| %>
  <%= f.text_field :title, class: "input-dark" %>
  <%= f.submit "Save", class: "btn-primary" %>
<% end %>
```

### Don't Build JSON APIs When HTML Works

**❌ Wrong:**
```ruby
# Controller returning JSON
def index
  render json: @documents
end

# Then using fetch() in JavaScript to render
```

**✅ Right:**
```ruby
# Controller returning HTML
def index
  @documents = current_user.documents
end

# View renders with ERB
<% @documents.each do |doc| %>
  <%= render doc %>
<% end %>
```

### Don't Rebuild Core Infrastructure

**❌ Wrong:**
```ruby
# Building custom authentication
class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      # ...
    end
  end
end
```

**✅ Right:**
```ruby
# Use Devise (already configured)
# Just use: before_action :authenticate_user!
```

### Don't Hardcode Pricing/Navigation

**❌ Wrong:**
```erb
<div class="pricing-card">
  <h3>Pro Plan - $9/month</h3>
  <ul>
    <li>Unlimited AI cover letters</li>
    <li>Unlimited location checks</li>
  </ul>
</div>
```

**✅ Right:**
```erb
<% PricingConfig::PLANS.each do |plan_id, plan| %>
  <div class="card">
    <h3><%= plan[:display_name] %> - <%= plan[:price][:display] %></h3>
    <ul>
      <% plan[:features].each do |key, feature| %>
        <li><%= feature[:display] %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

### Don't Bypass Rails Validations

**❌ Wrong:**
```javascript
// Client-side validation only
if (email.includes('@')) {
  submitForm()
}
```

**✅ Right:**
```ruby
# Model validation (server-side)
class Document < ApplicationRecord
  validates :title, presence: true
  validates :content, length: { minimum: 10 }
end

# Then optionally add Stimulus for UX feedback
```

---

## 📁 Key Files & Locations

### Configuration
- `config/initializers/pricing_config.rb` - Pricing, features, limits
- `config/initializers/ui_config.rb` - Navigation, UI structure
- `config/initializers/ruby_llm.rb` - AI/LLM configuration
- `config/initializers/pay.rb` - Payment configuration

### Models
- `app/models/user.rb` - User with Devise, Pay, TrackableUsage
- `app/models/usage_event.rb` - Feature usage tracking
- `app/models/concerns/trackable_usage.rb` - Usage tracking methods

### AI Tools
- `app/ai/tools/base_tool.rb` - Base AI tool class
- `app/ai/tools/base_action_tool.rb` - Tool with feature gating
- `app/ai/tools/example_tool.rb` - Template for new tools
- `app/ai/schemas/example_schema.rb` - Template for schemas

### Controllers
- `app/controllers/checkouts_controller.rb` - Stripe checkout
- `app/controllers/billing_portal_controller.rb` - Stripe billing portal
- `app/controllers/webhooks/stripe_controller.rb` - Stripe webhooks

### Views
- `app/views/layouts/application.html.erb` - Authenticated layout
- `app/views/layouts/landing.html.erb` - Public landing layout
- `app/views/common/_nav.html.erb` - Navigation (driven by UiConfig)
- `app/views/shared/_flash.html.erb` - Flash messages

### Helpers
- `app/helpers/ai_helper.rb` - AI convenience methods
- `app/helpers/icon_helper.rb` - Icon rendering (from UiConfig)

### Styles
- `app/assets/tailwind/application.css` - Tailwind + @layer components
- `app/assets/stylesheets/application.css` - Custom CSS (animations, etc.)

### JavaScript
- `app/javascript/controllers/auto_dismiss_controller.js` - Flash auto-dismiss
- `app/javascript/controllers/back_button_controller.js` - Back navigation

---

## 🎯 Summary

When building new features in this skeleton:

1. **Follow The Rails Way** - Server-side rendering, Turbo/Stimulus, minimal JS
2. **Use existing patterns** - TrackableUsage, BaseActionTool, config-driven
3. **Update configs** - PricingConfig for features, UiConfig for navigation
4. **Use components** - `.btn-primary`, `.card`, etc. for consistent UI
5. **Leverage RubyLLM** - For any AI features
6. **Don't rebuild** - Authentication, payments, jobs already configured

**The goal:** Build features that feel native to this Rails 8 app, not bolted on.
