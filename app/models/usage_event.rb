# == Schema Information
#
# Table name: usage_events
#
#  id         :bigint           not null, primary key
#  count      :integer
#  event_type :string
#  metadata   :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_usage_events_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UsageEvent < ApplicationRecord
  belongs_to :user

  validates :event_type, presence: true
  validates :count, presence: true, numericality: { greater_than: 0 }

  # Scopes for querying usage
  scope :for_feature, ->(feature) { where(feature: feature) }
  scope :current_month, -> { where("created_at >= ?", Time.current.beginning_of_month) }
  scope :current_day, -> { where("created_at >= ?", Time.current.beginning_of_day) }


  enum :event_type, {
    feature_1: "feature_1",
    feature_2: "feature_2",
    feature_3: "feature_3"
  }
end
