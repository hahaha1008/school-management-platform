# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Clear existing data
puts "Clearing existing data..."
Submission.destroy_all
Assignment.destroy_all
Enrollment.destroy_all
Course.destroy_all
Profile.destroy_all
User.destroy_all

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  user_name: 'admin',
  password: 'password',
  role: 'admin',
  expire_date: 1.year.from_now
)
admin.create_profile!(
  phone_num: '905-555-0000',
  address: 'McMaster University, 1280 Main St W, Hamilton, ON',
  major: 'N/A'
)

# Create instructors
puts "Creating instructors..."
instructors = [
  {
    user_name: 'professor_smith',
    password: 'password',
    role: 'instructor',
    profile: { 
      phone_num: '905-555-1111',
      address: '123 University Ave, Hamilton, ON',
      major: 'N/A'
    }
  },
  {
    user_name: 'dr_jones',
    password: 'password',
    role: 'instructor',
    profile: { 
      phone_num: '905-555-2222',
      address: '456 College Blvd, Hamilton, ON',
      major: 'N/A'
    }
  }
]

instructor_records = instructors.map do |instructor_data|
  profile_data = instructor_data.delete(:profile)
  instructor = User.create!(instructor_data)
  instructor.create_profile!(profile_data)
  instructor
end

# Create students
puts "Creating students..."
students = [
  {
    user_name: 'john_student',
    password: 'password',
    role: 'student',
    profile: { 
      phone_num: '905-555-3333',
      address: '789 Campus Dr, Hamilton, ON',
      major: 'Computer Science'
    }
  },
  {
    user_name: 'sara_student',
    password: 'password',
    role: 'student',
    profile: { 
      phone_num: '905-555-4444',
      address: '101 Scholar St, Hamilton, ON',
      major: 'Engineering'
    }
  },
  {
    user_name: 'mike_student',
    password: 'password',
    role: 'student',
    profile: { 
      phone_num: '905-555-5555',
      address: '202 Academic Rd, Hamilton, ON',
      major: 'Business'
    }
  }
]

student_records = students.map do |student_data|
  profile_data = student_data.delete(:profile)
  student = User.create!(student_data)
  student.create_profile!(profile_data)
  student
end

# Create courses
puts "Creating courses..."
courses = [
  {
    course_name: 'Introduction to Programming',
    description: 'An introductory course to programming concepts using Python.',
    instructor_id: instructor_records[0].id,
    term: 2025
  },
  {
    course_name: 'Data Structures',
    description: 'Study of fundamental data structures and algorithms.',
    instructor_id: instructor_records[0].id,
    term: 2025
  },
  {
    course_name: 'Database Systems',
    description: 'Introduction to database design, implementation and management.',
    instructor_id: instructor_records[1].id,
    term: 2025
  }
]

course_records = courses.map do |course_data|
  Course.create!(course_data)
end

# Create enrollments
puts "Creating enrollments..."
enrollments = [
  { user: student_records[0], course: course_records[0], status: 'active' },
  { user: student_records[0], course: course_records[1], status: 'active' },
  { user: student_records[1], course: course_records[0], status: 'active' },
  { user: student_records[1], course: course_records[2], status: 'active' },
  { user: student_records[2], course: course_records[1], status: 'active' },
  { user: student_records[2], course: course_records[2], status: 'active' }
]

enrollment_records = enrollments.map do |enrollment_data|
  Enrollment.create!(enrollment_data)
end

# Create assignments
puts "Creating assignments..."
assignments = [
  {
    course: course_records[0],
    ass_title: 'Hello World Program',
    ass_description: 'Write a simple program to print "Hello, World!" to the console.',
    due_date: 2.weeks.from_now
  },
  {
    course: course_records[0],
    ass_title: 'Calculator App',
    ass_description: 'Create a simple calculator that can perform basic arithmetic operations.',
    due_date: 4.weeks.from_now
  },
  {
    course: course_records[1],
    ass_title: 'Linked List Implementation',
    ass_description: 'Implement a linked list data structure with basic operations.',
    due_date: 3.weeks.from_now
  },
  {
    course: course_records[2],
    ass_title: 'Database Design',
    ass_description: 'Design a database schema for a simple e-commerce application.',
    due_date: 2.weeks.from_now
  }
]

assignment_records = assignments.map do |assignment_data|
  Assignment.create!(assignment_data)
end

# Create submissions
puts "Creating submissions..."
submissions = [
  {
    user: student_records[0],
    assignment: assignment_records[0],
    grade: 95,
    submit_time: 1.day.ago
  },
  {
    user: student_records[1],
    assignment: assignment_records[0],
    grade: 88,
    submit_time: 2.days.ago
  },
  {
    user: student_records[0],
    assignment: assignment_records[1],
    grade: nil,
    submit_time: 6.hours.ago
  }
]

submission_records = submissions.map do |submission_data|
  Submission.create!(submission_data)
end

puts "Seed data created successfully!"
puts "-----------------------------"
puts "Test Accounts:"
puts "Admin: username: admin, password: password"
puts "Instructor: username: professor_smith, password: password"
puts "Student: username: john_student, password: password"