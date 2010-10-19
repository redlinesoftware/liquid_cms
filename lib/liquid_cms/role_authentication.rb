module Cms
  module RoleAuthentication
    def authenticate_user(role, action_options = {})
      before_filter(action_options) {|controller| controller.authorize_role(role)}
    end
  end
end
