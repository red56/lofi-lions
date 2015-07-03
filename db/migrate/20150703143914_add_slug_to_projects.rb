class AddSlugToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :slug, :string
    Project.reset_column_information
    reversible do |dir|
      dir.up do
        Project.find_each do |project|
          project.save!
        end
      end
    end
  end
end
