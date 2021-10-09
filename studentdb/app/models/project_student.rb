# frozen_string_literal: true

class ProjectStudent < ApplicationRecord
  belongs_to :project
  belongs_to :student
  validates_uniqueness_of :student, scope: :project, message: 'is already on project'
end
