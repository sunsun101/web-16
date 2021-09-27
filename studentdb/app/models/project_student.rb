# frozen_string_literal: true

class ProjectStudent < ApplicationRecord
  belongs_to :project
  belongs_to :student
end
