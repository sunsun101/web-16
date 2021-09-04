# frozen_string_literal: true

# Mailer using the Gmail API
class GmailApiMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  default reply_to: ->(*) { 'no-reply@web16.cs.ait.ac.th' }

  # MailerInterceptor intercepts each message sent by Devise, refreshes the current Gmail API access token
  # if needed, and uses the Gmail API to send the message.
  class MailerInterceptor
    # GoogleHttpActionmailer expects an authorization object with a method apply! that adds necessary
    # authentication information to the outgoing message's headers. In our case, the apply! method adds an
    # "Authorization" header to the message containing the string "Bearer <ACCESS_TOKEN>"
    class Oauth2Authorization
      attr_accessor :token

      def initialize(token)
        @token = token.token
      end

      def apply!(headers)
        headers['Authorization'] = "Bearer #{token}"
      end
    end

    # delivering_email is called for each outgoing message. In our case, we grab the current Gmail API
    # access token and refresh token, refresh the access token if necessary, then tell ActionMailer to
    # use the GoogleHttpActionmailer delivery method initialized with the now-current access token.

    def self.create_oauth_strategy
      client_id = Rails.application.config.gmail_api_secrets['client_id']
      client_secret = Rails.application.config.gmail_api_secrets['client_secret']
      ::OmniAuth::Strategies::GoogleOauth2.new(nil, client_id, client_secret)
    end

    def self.create_new_oauth_token(client)
      access_token = Rails.application.config.gmail_api_tokens['access_token']
      refresh_token = Rails.application.config.gmail_api_tokens['refresh_token']
      token = OAuth2::AccessToken.new client, access_token, { refresh_token: refresh_token }
      token.refresh!
    end

    def self.delivering_email(message)
      strategy = create_oauth_strategy
      new_token = create_new_oauth_token(strategy.client)
      authorization = Oauth2Authorization.new new_token
      message.delivery_method(GoogleHttpActionmailer::DeliveryMethod, { authorization: authorization })
      message
    end
  end
  register_interceptor MailerInterceptor
end
