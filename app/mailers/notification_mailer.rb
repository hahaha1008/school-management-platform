# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
    default from: "notifications@mcmaster-student-mgmt.com"
    
    def assignment_due_reminder(user, assignment)
      @user = user
      @assignment = assignment
      @course = assignment.course
      
      mail(
        to: @user.email,
        subject: "Reminder: #{@assignment.ass_title} is due soon"
      )
    end
    
    def grade_notification(submission)
      @user = submission.user
      @submission = submission
      @assignment = submission.assignment
      @course = @assignment.course
      
      mail(
        to: @user.email,
        subject: "Your assignment has been graded"
      )
    end
    
    def new_assignment_notification(user, assignment)
      @user = user
      @assignment = assignment
      @course = assignment.course
      
      mail(
        to: @user.email,
        subject: "New Assignment: #{@assignment.ass_title}"
      )
    end
  end