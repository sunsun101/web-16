# frozen_string_literal: true

# Student controller class
class StudentsController < ApplicationController
  before_action :set_student, only: %i[ show edit update destroy ]
  before_action :set_project

  # GET /students or /students.json
  def index
    @students = Student.all
  end

  # GET /students/1 or /students/1.json
  def show; end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit; end

  # POST /students or /students.json
  def create
    @student = @project.students.create(student_params)
    respond_to do |format|
      if @student.id
        format.html { redirect_to @project, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to [@project, @student], notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: [@project, @student] }
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
      format.html { redirect_to project_students_url(@project), notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  # Only allow a list of trusted parameters through.
  def student_params
    params.require(:student).permit(:studentid, :name)
  end
end
