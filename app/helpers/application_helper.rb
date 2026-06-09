module ApplicationHelper
  HEIGHTS = MeasurementUnits::HEIGHTS
  WEIGHTS = MeasurementUnits::WEIGHTS
  DISTANCES = MeasurementUnits::DISTANCES
  TIMES = MeasurementUnits::TIMES

  def app_version
    ENV['APP_VERSION'] || '1.0.0'
  end

  def app_build_date
    ENV['BUILD_DATE'] || Time.current.to_date.to_s
  end

  def height_placeholder(unit)
    if unit == HEIGHTS::FT
      value = rand(4.00..6.11)
    elsif unit == HEIGHTS::CM
      value = rand(130..185)
    elsif unit == HEIGHTS::M
      value = rand(1.30..1.85)
    else
      value = rand(4.0..6.0)
    end

    t('preferences.placeholder', value: value, unit: unit)
  end

  def weight_placeholder(unit)
    value = (unit == WEIGHTS::KG) ? rand(70..90) : rand(154..220)
    t('preferences.placeholder', value: value, unit: unit)
  end

  def distance_placeholder(unit)
    t('preferences.placeholder', value: rand(1..10), unit: unit)
  end
end
