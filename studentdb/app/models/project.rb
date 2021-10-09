# frozen_string_literal: true

# Project model class
class Project < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :url
  has_many :project_students, dependent: :destroy
  has_many :students, through: :project_students
  accepts_nested_attributes_for :students, allow_destroy: true, reject_if: :reject_students

  def reject_students(attributes)
    if attributes['_destroy_r'].to_i != 0
      student = students.where(id: attributes['id'])
      students.destroy(student) if student
      student&.first&.destroy
      return true
    end
    attributes['studentid'].blank? and attributes['name'].blank?
  end

  def add_student(attributes)
    student = Student.find_or_create_by_studentid attributes[:studentid]
    errors[:students] << 'already has the requested student' and return false if students.include? student

    students.append student
  end
end
