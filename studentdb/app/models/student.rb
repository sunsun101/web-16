# frozen_string_literal: true

# Model class for student records
class Student < ApplicationRecord
  has_many :project_students, dependent: :destroy
  has_many :projects, through: :project_students
  validates_presence_of :name
  validates_presence_of :studentid
  validates_uniqueness_of :studentid
  accepts_nested_attributes_for :projects, allow_destroy: true, reject_if: :reject_projects
  attr_accessor :_destroy_r

  def reject_projects(attributes)
    attributes['name'].blank? and attributes['url'].blank?
  end
end
