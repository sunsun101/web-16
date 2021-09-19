# frozen_string_literal: true

# Test class for StudentsController
class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @student = students(:one)
  end

  test 'should get index' do
    get project_students_url(@project)
    assert_response :success
  end

  test 'should get new' do
    get new_project_student_url(@project)
    assert_response :success
  end

  test 'should create project' do
    assert_difference('Student.count') do
      post project_students_url(@project), params: { student: { name: 'Jane Student', studentid: '123459' } }
    end
    assert_redirected_to project_url(@project)
  end

  test 'should fail to create student' do
    assert_difference('Student.count', 0) do
      post project_students_url(@project), params: { student: { name: '', url: '', project_id: nil } }
    end
    assert_response :success
    assert_select 'li', /.+/
  end

  test 'should show student' do
    get project_student_url(@project, @student)
    assert_response :success
  end

  test 'should get edit' do
    get edit_project_student_url(@project, @student)
    assert_response :success
  end

  test 'should update student' do
    patch project_student_url(@project, @student),
          params: { student: { name: @student.name, studentid: @student.studentid } }
    assert_redirected_to project_student_url(@project, @student)
  end

  test 'should fail to update student' do
    patch project_student_url(@project, @student), params: { student: { name: '', studentid: '' } }
    assert_response :unprocessable_entity
  end

  test 'should destroy project' do
    assert_difference('Student.count', -1) do
      delete project_student_url(@project, @student)
    end

    assert_redirected_to project_students_url
  end
end
