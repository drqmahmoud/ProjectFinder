class AddViewsToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :views, :integer, null: false, default:0
  end
end
