class AdminController < ApplicationController
  before_action :ensure_admin

  def delete_user
    @user = User.find(params[:user_id])
    @user.destroy!

    flash[:notice] = 'User deleted'
    redirect_to volunteers_path
  end

  def toggle_highlight
    @project = Project.find(params[:project_id])
    @project.highlight = !@project.highlight
    @project.save

    flash[:notice] = @project.highlight? ? 'Project highlighted' : 'Removed highlight on project'
    redirect_to project_path(@project)
  end

  def approve_project
    @project = Project.find(params[:project_id])
    @project.approved = TRUE
    @project.save

    $unapproved_projects = Project.get_unapproved

    flash[:notice] = @project.approved? ? 'Project approved' : 'There was an error approving the project'
    redirect_to project_path(@project)
  end

  def deny_project
    @project = Project.find(params[:project_id])
    @project.approved = FALSE
    @project.save

    flash[:notice] = !@project.approved? ? 'Project denied' : 'There was an error denying the project'
    redirect_to project_path(@project)
  end
end
