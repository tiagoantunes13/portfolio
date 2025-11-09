# == Schema Information
#
# Table name: projects
#
#  id           :bigint           not null, primary key
#  description  :text
#  featured     :boolean          default(FALSE)
#  github_url   :string
#  position     :integer          default(0)
#  project_url  :string
#  technologies :text
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Project < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true

  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :featured, -> { where(featured: true) }
end
