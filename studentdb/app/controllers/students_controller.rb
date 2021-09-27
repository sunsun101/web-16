# frozen_string_literal: true

# Student controller class
class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  # GET /students or /students.json
  def index
    @students = Student.all
  end

  # GET /students/1 or /students/1.json
  def show; end

  # GET /students/new
  def new
    @student = Student.new
    @student.projects.build
  end

  # GET /students/1/edit
  def edit
    @student.projects.build
  end

  # POST /students or /students.json
  def create
    @student = Student.create(student_params)
    respond_to do |format|
      if @student.id
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  # Get list of IDs from projects attributes
  def existing_project_ids(filtered_parms)
    filtered_parms[:projects_attributes]&.values&.collect { |p| p[:id] }&.compact
  end

  # Only allow a list of trusted parameters through.
  def student_params
    filtered_params = params.require(:student).permit(
      :studentid, :name, project_ids: [], projects_attributes: %i[id name url _destroy]
    )
    filtered_params[:project_ids] |= existing_project_ids(filtered_params)
    filtered_params
  end
end
