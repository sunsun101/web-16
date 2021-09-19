# frozen_string_literal: true

# Unit tests for the Student model class
class StudentTest < ActiveSupport::TestCase
  test 'should be valid' do
    Student.all.each { |s| assert s.valid? }
  end

  test 'should validate' do
    student = Student.new
    assert !student.valid?, 'Blank student should be invalid'
    assert_equal ["can't be blank"], student.errors[:name]
    assert_equal ["can't be blank"], student.errors[:studentid]
    student.name = 'A name'
    student.studentid = students(:one).studentid
    assert !student.valid?, 'Non-unique studentid should be invalid'
    assert_equal ['has already been taken'], student.errors[:studentid]
  end
end
