# frozen_string_literal: true

class ProfessionalAssignment < ApplicationRecord
  belongs_to :client, class_name: 'User', inverse_of: :professional_assignment
  belongs_to :nutritionist, class_name: 'User', optional: true
  belongs_to :physical_educator, class_name: 'User', optional: true

  validate :professionals_are_valid
  validate :not_self_assigned

  private

  def professionals_are_valid
    if nutritionist.present? && !nutritionist.valid_nutritionist?
      errors.add(:nutritionist,
                 'must be a valid nutritionist')
    end
    return unless physical_educator.present? && !physical_educator.valid_physical_educator?

    errors.add(:physical_educator, 'must be a valid physical educator')
  end

  def not_self_assigned
    errors.add(:base, 'cannot assign a professional to themselves') if
      [nutritionist_id, physical_educator_id].compact.include?(client_id)
  end
end
