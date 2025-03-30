class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.references :course, null: false, foreign_key: true
      t.string :ass_title
      t.text :ass_description
      t.datetime :due_date

      t.timestamps
    end
  end
end
