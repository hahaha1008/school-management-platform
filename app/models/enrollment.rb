# app/models/enrollment.rb
class Enrollment < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :course
  
  # Validations
  validates :status, presence: true, inclusion: { in: %w(active dropped completed) }
  validates :user_id, uniqueness: { scope: :course_id, message: "is already enrolled in this course" }
  
  # Scope for active enrollments
  scope :active, -> { where(status: 'active') }
end