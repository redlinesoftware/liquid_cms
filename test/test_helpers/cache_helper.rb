class ActionController::IntegrationTest
  def assert_cache_key(key, clear = true)
    assert_equal key, Rails.cache.instance_variable_get(:@data).to_a.try(:first).try(:first)
    Rails.cache.clear if clear == true
  end

  def assert_cache_present
    assert Rails.cache.instance_variable_get(:@data).present?
  end

  def assert_cache_empty
    assert Rails.cache.instance_variable_get(:@data).blank?
  end
end
