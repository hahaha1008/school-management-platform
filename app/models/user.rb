# app/models/user.rb
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  
  # Validations
  validates :user_name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w(student instructor admin) }
  
  # Relationships
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :submissions, dependent: :destroy
  has_many :taught_courses, class_name: 'Course', foreign_key: 'instructor_id'
  
  # Authentication method for legacy system
  def self.authenticate(user_name, password)
    user = find_by(user_name: user_name)
    return user if user && user.valid_password?(password)
    nil
  end
  
  # Authorization methods
  def student?
    role == 'student'
  end
  
  def instructor?
    role == 'instructor'
  end
  
  def admin?
    role == 'admin'
  end
  
  # Add email to user (required for Devise)
  def email_required?
    false # Make email optional for backward compatibility
  end
  
  def email
    self[:email] || "#{user_name}@example.com" # Fallback email if not set
  end
end