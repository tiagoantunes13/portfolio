class AddDetailsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :slug, :string
    add_index :projects, :slug
    add_column :projects, :role, :string
    add_column :projects, :key_features, :text
    add_column :projects, :highlights, :text
  end
end
