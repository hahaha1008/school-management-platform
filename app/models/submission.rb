# app/models/submission.rb
class Submission < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :assignment
  
  # Validations
  validates :user_id, uniqueness: { scope: :assignment_id, message: "has already submitted this assignment" }
  
  # Callbacks
  before_create :set_submit_time
  
  private
  
  def set_submit_time
    self.submit_time = Time.current
  end
end