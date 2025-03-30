# app/models/course.rb
class Course < ApplicationRecord
    # Relationships
    belongs_to :instructor, class_name: 'User', foreign_key: 'instructor_id'
    has_many :enrollments, dependent: :destroy
    has_many :students, through: :enrollments, source: :user
    has_many :assignments, dependent: :destroy
    
    # Validations
    validates :course_name, presence: true
    validates :description, presence: true
    validates :term, presence: true
  end