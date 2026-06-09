class ApplicationRecord < ActiveRecord::Base
  include MeasurementUnits

  self.abstract_class = true
end
