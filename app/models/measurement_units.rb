# frozen_string_literal: true

module MeasurementUnits
  module WEIGHTS
    KG = 'kg'
    LBS = 'lbs'
    ALL = [KG, LBS].freeze
  end

  module DISTANCES
    KM = 'km'
    MI = 'mi'
    ALL = [KM, MI].freeze
  end

  module HEIGHTS
    M = 'm'
    FT = 'ft'
    CM = 'cm'
    ALL = [M, FT, CM].freeze
  end

  module TIMES
    MINUTES = 'min'
    SECONDS = 's'
    ALL = [MINUTES, SECONDS].freeze
  end

  module TYPES
    HEIGHT = 'height'
    WEIGHT = 'weight'
    DISTANCE = 'distance'
    SPEED = 'speed'
    TIME = 'time'
    ALL = [HEIGHT, WEIGHT, DISTANCE, SPEED, TIME].freeze
  end
end
