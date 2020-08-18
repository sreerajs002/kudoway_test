class CreateStandups < ActiveRecord::Migration[6.0]
  def change
    create_table :standups do |t|
      t.references :user, null: false, foreign_key: true
      t.text :worklog

      t.timestamps
    end
  end
end
