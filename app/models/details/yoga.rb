# frozen_string_literal: true

module Details
  class Yoga < Base
    VALID_STYLES = %w[hatha vinyasa ashtanga yin kundalini bikram power restorative].freeze

    attribute :style, :string

    validates :style, inclusion: { in: VALID_STYLES }, allow_blank: true
  end
end
