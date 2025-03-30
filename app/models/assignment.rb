# app/models/assignment.rb
class Assignment < ApplicationRecord
  # Relationships
  belongs_to :course
  has_many :submissions, dependent: :destroy
  
  # Validations
  validates :ass_title, presence: true
  validates :ass_description, presence: true
  validates :due_date, presence: true
  
  # Scope for upcoming assignments
  scope :upcoming, -> { where('due_date > ?', Time.current) }
  
  # Scope for past assignments
  scope :past, -> { where('due_date <= ?', Time.current) }
end