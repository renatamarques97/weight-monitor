# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfessionalAssignment, type: :model do
  describe 'validations' do
    it 'links valid professionals to a client' do
      client = create(:user)
      nutritionist = create(:user, account_type: :professional, professional_type: :nutritionist,
                                   country_code: 'BR', professional_credential: 'CRN',
                                   professional_registration_number: '123')
      educator = create(:user, account_type: :professional, professional_type: :physical_educator,
                               country_code: 'BR', professional_credential: 'CREF',
                               professional_registration_number: '456')

      expect(described_class.new(client:, nutritionist:, physical_educator: educator)).to be_valid
    end

    it 'rejects a professional assigned to themselves' do
      user = create(:user, account_type: :professional, professional_type: :nutritionist,
                           country_code: 'BR', professional_credential: 'CRN',
                           professional_registration_number: '123')

      expect(described_class.new(client: user, nutritionist: user)).not_to be_valid
    end

    it 'rejects an invalid nutritionist' do
      assignment = described_class.new(client: create(:user), nutritionist: create(:user, account_type: :free))

      expect(assignment).not_to be_valid
      expect(assignment.errors[:nutritionist]).to be_present
    end

    it 'rejects an invalid physical educator' do
      assignment = described_class.new(client: create(:user), physical_educator: create(:user, account_type: :free))

      expect(assignment).not_to be_valid
      expect(assignment.errors[:physical_educator]).to be_present
    end
  end
end
