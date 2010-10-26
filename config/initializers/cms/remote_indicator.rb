begin
  RemoteIndicator.default_image = '/cms/images/indicator.gif'
rescue NameError
  # RemoteIndicator won't exist when the generator runs, so ignore the error
end

