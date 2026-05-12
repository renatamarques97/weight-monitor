# frozen_string_literal: true

module Details
  class Base
    include StoreModel::Model

    attribute :notes, :string

    def to_s
      as_json.compact.map { |key, value| "#{key}=#{value}" }.join(", ")
    end
  end
end
