# frozen_string_literal: true

require 'test_helper'

# Project model unit tests
class ProjectTest < ActiveSupport::TestCase
  test 'Project is valid' do
    assert projects(:one).valid?
    assert projects(:two).valid?
  end

  test 'should validate presence of name' do
    project = Project.new
    assert !project.valid?
    assert_equal ["can't be blank"], project.errors[:name]
  end

  test 'should validate uniqueness of name' do
    old_project = projects(:one)
    project = Project.new name: old_project.name
    assert !project.valid?
    assert_equal ['has already been taken'], project.errors[:name]
  end

  test 'should destroy associated student' do
    project = project_students(:one).project
    student = project.students.first
    id = student.id
    project.update(students_attributes: [{ id: student.id.to_s, _destroy_r: '1' }])
    assert Student.find_by_id(id).nil?
    count = project.students.size
    project.update(students_attributes: [{ studentid: '', name: '' }])
    assert_equal count, project.students.size
  end
end
