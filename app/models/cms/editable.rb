module Cms
  class Editable
    def self.content_type(name)
      case name
      when /\.css\Z/
        "text/css"
      when /\.js\Z/
        "text/javascript"
      when /\.xml\Z/
        "text/xml"
      when /\.json\Z/
        "application/json"
      when /\.txt\Z/
        "text/plain"
      else
        "text/html"
      end
    end 
  end
end
