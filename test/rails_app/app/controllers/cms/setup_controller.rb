class Cms::SetupController < ApplicationController
  # filters and other customizations can be made here before the cms controllers are run

  # Returns the current user for the application.
  # Remove this method if your application already defines a current_user method
  # or provide valid code that returns a user object for the current user.
  def current_user
    @company.users.first
  end

  # Define your own authorization logic given one of the cms roles... :all, :cms_admin, :cms_user
  def authorize_role(role)
    authorized = case role
    when :all, :cms_admin, :cms_user
      current_user.present?
    else
      false
    end

    redirect_to '/login' unless authorized

    return authorized
  end
end
