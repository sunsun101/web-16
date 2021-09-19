# frozen_string_literal: true

class Student < ApplicationRecord
  has_many :project_students
  has_many :projects, through: :project_students
  validates_presence_of :name
  validates_presence_of :studentid
  validates_uniqueness_of :studentid
end
