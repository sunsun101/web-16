# frozen_string_literal: true

# Controller for the projects resource
class ProjectsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_project, only: %i[show edit update destroy add_student]

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show; end

  # GET /projects/new
  def new
    authorize Project
    @project = Project.new
    @project.students.build
  end

  # GET /projects/1/edit
  def edit
    @project.students.build
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    authorize @project
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /projects/:id/students

  def add_student
    authorize params[:student], :add_to_project?, policy_class: StudentPolicy
    respond_to do |format|
      if @project.add_student params[:student]
        format.html { redirect_to @project, notice: 'Student was successfully added.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Get list of IDs from students attributes
  def existing_student_ids(filtered_parms)
    filtered_parms[:students_attributes]&.values&.collect { |s| s[:id] }&.compact
  end

  # Only allow a list of trusted parameters through.
  def project_params
    filtered_params = params.require(:project).permit(policy(@project || Project).permitted_attributes)
    filtered_params[:student_ids] |= existing_student_ids(filtered_params)
    filtered_params
  end
end
