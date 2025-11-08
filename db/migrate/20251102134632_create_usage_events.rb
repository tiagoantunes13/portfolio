class CreateUsageEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :usage_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_type
      t.integer :count
      t.jsonb :metadata

      t.timestamps
    end
  end
end
