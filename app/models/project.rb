# == Schema Information
#
# Table name: projects
#
#  id           :bigint           not null, primary key
#  description  :text
#  featured     :boolean          default(FALSE)
#  github_url   :string
#  highlights   :text
#  key_features :text
#  position     :integer          default(0)
#  project_url  :string
#  role         :string
#  slug         :string
#  technologies :text
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_projects_on_slug  (slug)
#
class Project < ApplicationRecord
  has_many_attached :images

  validates :title, presence: true
  validates :description, presence: true
  validates :slug, uniqueness: true, presence: true

  before_validation :generate_slug, if: -> { slug.blank? || title_changed? }

  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :featured, -> { where(featured: true) }

  # Use slug for URLs instead of id
  def to_param
    slug
  end

  # Primary image is the first attached image, fallback for backwards compatibility
  def primary_image
    images.first
  end

  private

  def generate_slug
    base_slug = title.parameterize
    self.slug = base_slug

    # Ensure uniqueness by appending a number if necessary
    counter = 1
    while Project.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
