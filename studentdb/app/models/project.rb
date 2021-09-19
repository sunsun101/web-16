# frozen_string_literal: true

class Project < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :url
  has_many :project_students
  has_many :students, through: :project_students
end
