# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Jbuilder.key_format camelize: :lower
Jbuilder.deep_format_keys camelize: :lower
Rails.application.initialize!
