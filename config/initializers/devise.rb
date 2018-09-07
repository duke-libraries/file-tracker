Devise.setup do |config|

  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  require 'devise/orm/active_record'

  config.authentication_keys = [:uid]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.sign_out_via = :delete

  require 'omniauth-shibboleth'
  config.omniauth :shibboleth,
                  uid_field: "eppn",
                  info_fields: { email: "mail" }

end
