class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_company

  def load_company
    @company = Company.first
    Cms.set_context @company, self
  end
end
