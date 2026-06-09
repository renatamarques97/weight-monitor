module MeasurementUnits
  module WEIGHTS
    KG = 'kg'.freeze
    LBS = 'lbs'.freeze
    ALL = [KG, LBS].freeze
  end

  module DISTANCES
    KM = 'km'.freeze
    MI = 'mi'.freeze
    ALL = [KM, MI].freeze
  end

  module HEIGHTS
    M = 'm'.freeze
    FT = 'ft'.freeze
    CM = 'cm'.freeze
    ALL = [M, FT, CM].freeze
  end

  module TIMES
    MINUTES = 'min'.freeze
    SECONDS = 's'.freeze
    ALL = [MINUTES, SECONDS].freeze
  end

  module TYPES
    HEIGHT = 'height'.freeze
    WEIGHT = 'weight'.freeze
    DISTANCE = 'distance'.freeze
    SPEED = 'speed'.freeze
    TIME = 'time'.freeze
    ALL = [HEIGHT, WEIGHT, DISTANCE, SPEED, TIME].freeze
  end
end
