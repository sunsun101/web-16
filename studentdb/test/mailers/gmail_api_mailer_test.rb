# frozen_string_literal: true

require 'test_helper'

# module GoogleHttpActionmailer
#   # Override delivery to do nothing during a test
#   class DeliveryMethod
#     def deliver!(mail); end
#   end
# end

module Google
  module Apis
    module GmailV1
      # Override the send user message method to do nothing during a test
      class GmailService
        def send_user_message(_, _); end
      end
    end
  end
end

# Test our custom mailer that uses the Gmail API
class GmailApiMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:one)
    Rails.application.config.gmail_api_secrets = { client_id: 'FakeClientId', client_secret: 'FakeClientSecret' }
    Rails.application.config.gmail_api_tokens = { access_token: 'FakeToken', refresh_token: 'FakeToken' }
  end

  # Before sending, need to stub out the Google API access token refresh process
  class FakeToken
    def token
      'fake'
    end
  end

  test 'should send confirmation instructions' do
    mailer = GmailApiMailer.new
    email = mailer.confirmation_instructions @user, 'UserToken'
    # Before sending, need to stub out the deliver! method to prevent real delivery
    mock_access_token = Minitest::Mock.new
    def mock_access_token.refresh!
      FakeToken.new
    end
    OAuth2::AccessToken.stub :new, mock_access_token do
      # Send the message, with the remote services stubbed out
      email.deliver
    end
    assert_equal 'fake', email.delivery_method.service.authorization.token
    assert_equal email.to, [@user.email]
    headers = {}
    email.delivery_method.service.authorization.apply!(headers)
    assert_equal 'Bearer fake', headers['Authorization']
  end

  test 'should instantiate applicationmailer' do
    am = ApplicationMailer.new
    assert am
  end
end
