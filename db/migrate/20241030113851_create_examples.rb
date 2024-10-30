class CreateExamples < ActiveRecord::Migration[7.2]
  def change
    create_table :examples do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
