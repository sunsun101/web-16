# frozen_string_literal: true

# Superclass for all active record models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
