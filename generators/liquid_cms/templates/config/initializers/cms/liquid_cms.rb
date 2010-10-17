Cms.setup do |config|
  # To allow proper access to the cms, define a callback method in Cms::SetupController or a parent controller
  # that accepts a role symbol and returns true/false if the user should be given access to various cms functions.
  # The role parameter will be one of :all, :cms_admin or :cms_user
  #
  # def authorize_role(role)
  #   res = current_user.admin? && role == :cms_admin
  #   redirect_to login_path if !res
  #   res
  # end
  #
  #config.user_authorize_callback = :authorize_role

  # The class of your apps context object if it has one. This attribute must be set last.
  #config.context_class = :Context
end
