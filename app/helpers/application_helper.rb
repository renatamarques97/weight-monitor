module ApplicationHelper
  def app_version
    ENV['APP_VERSION'] || '1.0.0'
  end

  def app_build_date
    ENV['BUILD_DATE'] || Time.current.to_date.to_s
  end
end
