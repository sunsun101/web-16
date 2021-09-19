# frozen_string_literal: true

require 'test_helper'

# Test class for SiteController
class SiteControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should get index' do
    get site_index_url
    assert_response :success
  end

  test 'should authenticate get admin_dashboard' do
    get admin_dashboard_url
    assert_redirected_to new_user_session_path
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
  end

  test 'should authorize get admin dashboard' do
    sign_in users(:two)
    get admin_dashboard_url
    assert_redirected_to root_path
    assert_equal 'You attempted an unauthorized action.', flash[:alert]
  end
end
