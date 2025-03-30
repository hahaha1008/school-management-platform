class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :course_name
      t.text :description
      t.integer :instructor_id
      t.integer :term

      t.timestamps
    end
  end
end
