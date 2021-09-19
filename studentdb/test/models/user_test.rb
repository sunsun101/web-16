# frozen_string_literal: true

require 'test_helper'

# Tests for the user model class
class UserTest < ActiveSupport::TestCase
  test 'should be valid' do
    User.all.each { |u| assert u.valid?, 'Fixture should be valid' }
  end

  test 'first user should become admin' do
    User.all.each(&:destroy)
    user = User.create email: 'new_user@example.com', password: 'secret12', confirmed_at: '2020-09-09 07:01:51.461869'
    assert user.is_admin, user.errors.full_messages
  end
end
