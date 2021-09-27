# frozen_string_literal: true

require 'test_helper'

# Test class for ProjectsController
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @project = projects(:one)
  end

  test 'should get index' do
    get projects_url
    assert_response :success
  end

  test 'should get new' do
    sign_in users(:two)
    get new_project_url
    assert_response :success
  end

  test 'should create project' do
    sign_in users(:two)
    assert_difference('Project.count') do
      post projects_url, params: { project: { name: 'New project', url: @project.url } }
    end
    assert_redirected_to project_url(Project.last)
  end

  test 'should fail to create project' do
    sign_in users(:two)
    assert_difference('Project.count', 0) do
      post projects_url, params: { project: { name: '', url: '' } }
    end
    assert_response :unprocessable_entity
  end

  test 'should show project' do
    sign_in users(:two)
    get project_url(@project)
    assert_response :success
  end

  test 'should get edit' do
    sign_in users(:two)
    get edit_project_url(@project)
    assert_response :success
  end

  test 'should update project' do
    sign_in users(:two)
    patch project_url(@project), params: { project: { name: @project.name, url: @project.url } }
    assert_redirected_to project_url(@project)
  end

  test 'should fail to update project' do
    sign_in users(:two)
    patch project_url(@project), params: { project: { name: '', url: '' } }
    assert_response :unprocessable_entity
  end

  test 'should destroy project' do
    sign_in users(:two)
    assert_difference('Project.count', -1) do
      delete project_url(@project)
    end
    assert_redirected_to projects_url
  end
end
