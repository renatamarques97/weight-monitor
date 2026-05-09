# frozen_string_literal: true

module Details
  class Swimming < Base
    VALID_STYLES = %w[freestyle backstroke breaststroke butterfly medley].freeze

    attribute :style, :string
    attribute :laps, :integer

    validates :style, inclusion: { in: VALID_STYLES }, allow_blank: true
  end
end
