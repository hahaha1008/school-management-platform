# app/models/profile.rb
class Profile < ApplicationRecord
  # Relationships
  belongs_to :user
  
  # Validations
  validates :phone_num, presence: true
  validates :address, presence: true
  validates :major, presence: true, if: -> { user.student? }
end