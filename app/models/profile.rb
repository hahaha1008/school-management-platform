# app/models/profile.rb
class Profile < ApplicationRecord
  # Relationships
  belongs_to :user
  has_one_attached :avatar

  # Validations
  validates :phone_num, presence: true
  validates :address, presence: true
  validates :major, presence: true, if: -> { user.student? }
  validates :avatar, content_type: { in: %w[image/jpeg image/png image/gif],
                                    message: "must be a valid image format (JPEG, PNG, GIF)" },
                    size: { less_than: 5.megabytes,
                           message: "should be less than 5MB" }
  def display_avatar
    avatar.variant(resize_to_limit: [300, 300])
  end                    
end