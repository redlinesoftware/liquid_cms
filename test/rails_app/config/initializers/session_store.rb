# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_test_cms_session',
  :secret      => 'd1f618b128bf162bcea96d2739b0e45db26ef13c5de1c6ce3e59e1afee50e5f206f9a09d9b547835102bbb2d82fe2db216718a8af107ab04b9d517a662980143'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
