# frozen_string_literal: true

# Test class for StudentsController
class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:one)
  end

  test 'should get index' do
    get students_url
    assert_response :success
  end

  test 'should get new' do
    get new_student_url
    assert_response :success
  end

  test 'should create project' do
    assert_difference('Student.count') do
      post students_url, params: { student: { name: 'Jane Student', studentid: '123459' } }
    end
    assert_redirected_to student_url(Student.last)
  end

  test 'should fail to create student' do
    assert_difference('Student.count', 0) do
      post students_url, params: { student: { name: '', url: '', project_id: nil } }
    end
    assert_response :success
    assert_select 'li', /Name can't be blank/
  end

  test 'should show student' do
    get student_url(@student)
    assert_response :success
  end

  test 'should get edit' do
    get edit_student_url(@student)
    assert_response :success
  end

  test 'should update student' do
    patch student_url(@student),
          params: { student: { name: @student.name, studentid: @student.studentid } }
    assert_redirected_to student_url(@student)
  end

  test 'should fail to update student' do
    patch student_url(@student), params: { student: { name: '', studentid: '' } }
    assert_response :unprocessable_entity
  end

  test 'should destroy project' do
    assert_difference('Student.count', -1) do
      delete student_url(@student)
    end
    assert_redirected_to students_url
  end
end
