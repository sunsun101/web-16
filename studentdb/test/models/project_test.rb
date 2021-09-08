# frozen_string_literal: true

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test 'Project is valid' do
    assert projects(:one).valid?
    assert projects(:two).valid?
  end
end
