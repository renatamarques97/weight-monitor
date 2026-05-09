class Workout < ApplicationRecord
  belongs_to :user

  self.inheritance_column = :workout_type

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Workout')
  end

  enum :workout_type, WorkoutType::MAPPING

  def self.find_sti_class(type_name)
    type_label = if type_name.to_s.match?(/\A\d+\z/)
                   workout_types.key(type_name.to_i)
                 else
                   type_name
                 end

    type_label.to_s.camelize.constantize
  end

  def self.sti_name
    key = name.underscore.to_sym
    WorkoutType::MAPPING[key] || super
  end

  validates :workout_type, presence: true
  validates :workout_date, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
end
