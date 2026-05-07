# frozen_string_literal: true

module Details
  class MartialArts < Base
    VALID_STYLES = %w[jiu_jitsu muay_thai boxing karate judo taekwondo capoeira mma wrestling].freeze

    attribute :style, :string
    attribute :belt, :string

    validates :style, inclusion: { in: VALID_STYLES }, allow_blank: true
  end
end
