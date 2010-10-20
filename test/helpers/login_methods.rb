class ActiveSupport::TestCase
  def stub_paperclip!
    Paperclip::InstanceMethods.module_eval do
      def save_attached_files
        true
      end
    end
    Paperclip::Geometry.module_eval do
      def self.from_file(file)
        Paperclip::Geometry.new('20', '20')
      end
    end
  end
end

class ActionController::TestCase
  def set_company_host(company)
    @request.host = company.domain_name 
  end

  def setup_company_and_login_admin
    @company = Factory(:company)
    @user = @company.users.first
    set_company_host(@company)
  end

  def logout_user
    User.first.destroy
    #UserSession.find.try(:destroy)
  end
end

class ActionController::IntegrationTest
  FIXTURES_PATH = File.join(File.dirname(__FILE__), '..', 'fixtures') unless const_defined?('FIXTURES_PATH')

  def login_company(username, password)
  end

  def set_company_host(company)
    reset!
    host! company.domain_name
  end

  def read_fixture(action, options = nil)
    template = IO.readlines("#{FIXTURES_PATH}/liquid/#{action}").join
    if options
      vars = OpenStruct.new options
      ERB.new(template).result(vars.send(:binding))
    else
      template
    end
  end
end

