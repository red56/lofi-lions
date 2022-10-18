# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :slug
      t.timestamps null: false
    end

    add_column :master_texts, :project_id, :integer
    add_column :views, :project_id, :integer
    default_project = Project.create!(name: "Mobile")
    Project.create!(name: "Terms")
    Project.create!(name: "CM Blogging App")
    MasterText.update_all(project_id: default_project.id)
    View.update_all(project_id: default_project.id)
  end
end
