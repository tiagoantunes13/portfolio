class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.text :technologies
      t.string :project_url
      t.string :github_url
      t.integer :position, default: 0
      t.boolean :featured, default: false

      t.timestamps
    end
  end
end
