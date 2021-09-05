# frozen_string_literal: true

# Patch to the Google HTTP Actionmailer to fix bug in deliver! method
class MailerDeliveryMethod < GoogleHttpActionmailer::DeliveryMethod
  def deliver!(mail)
    user_id = message_options[:user_id] || 'me'
    message = Google::Apis::GmailV1::Message.new(
      raw:       mail.to_s,
      thread_id: mail['Thread-ID'].to_s
    )
    before_send = delivery_options[:before_send]
    if before_send && before_send.respond_to?(:call)
      before_send.call(mail, message)
    end
    # deliver! method in version 0.3.0 passes illegal 3rd option
    message = service.send_user_message(user_id, message)
    after_send = delivery_options[:after_send]
    if after_send && after_send.respond_to?(:call)
      after_send.call(mail, message)
    end
  end
end

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
      message.delivery_method(MailerDeliveryMethod, { authorization: authorization })
      message
    end
  end
  register_interceptor MailerInterceptor
end
