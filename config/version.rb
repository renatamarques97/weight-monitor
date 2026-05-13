# app/config/version.rb
# Application version configuration
module FitTracker
  VERSION = '1.0.0'
  BUILD_DATE = ENV['BUILD_DATE'] || Time.current.to_date.to_s
end
