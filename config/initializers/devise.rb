Devise.setup do |config|
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  require 'devise/orm/active_record'

  config.authentication_keys = [:uid]
  # config.request_keys = []
  # config.params_authenticatable = true
  # config.http_authenticatable = false
  # config.http_authenticatable_on_xhr = true
  # config.http_authentication_realm = 'Application'
  # config.paranoid = true
  config.skip_session_storage = [:http_auth]
  # config.clean_up_csrf_token_on_authentication = true
  # config.reload_routes = true
  config.stretches = Rails.env.test? ? 1 : 11
  # config.pepper = '11a5922e4318d639426f08dc8d0b6157a84059d130a68d87a555a707dcbc3e3196b4cac77754fdb89433ba7aedea287ddb241fa8a448bf876a5ea890c61d030c'
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.sign_out_via = :delete

  require 'omniauth-shibboleth'
  config.omniauth :shibboleth,
                  request_type: :header,
                  uid_field: "eppn",
                  name_field: "displayName",
                  info_fields: {
                    email: "mail",
                    first_name: "givenName",
                    last_name: "sn",
                    nickname: "eduPersonNickname"
                  }


end
