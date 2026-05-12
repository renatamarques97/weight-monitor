require 'rails_helper'

RSpec.describe Workout, type: :model do
  describe "relations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:workout_type) }
    it { is_expected.to validate_presence_of(:workout_date) }
    it { is_expected.to validate_presence_of(:duration) }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than(0) }
  end

  describe ".find_sti_class" do
    it "returns subclass from numeric type" do
      expect(described_class.find_sti_class(WorkoutType::RUNNING)).to eq(Running)
    end

    it "returns subclass from string type" do
      expect(described_class.find_sti_class("running")).to eq(Running)
    end

    it "returns subclass from string type for all sports" do
      WorkoutType::MAPPING.keys.each do |sport_key|
        expected_class = sport_key.to_s.camelize.constantize
        expect(described_class.find_sti_class(sport_key.to_s)).to eq(expected_class)
      end
    end
  end

  describe ".sti_name" do
    it "returns enum mapping value for subclass" do
      expect(Running.sti_name).to eq(WorkoutType::RUNNING)
    end

    it "returns correct sti_name for all subclasses" do
      WorkoutType::MAPPING.each do |sport_key, sport_value|
        subclass = sport_key.to_s.camelize.constantize
        expect(subclass.sti_name).to eq(sport_value)
      end
    end
  end

  describe ".model_name" do
    it "uses workout model name for STI subclasses" do
      expect(Running.model_name.name).to eq("Workout")
      expect(Running.model_name.param_key).to eq("workout")
    end

    it "uses workout model name for all subclasses" do
      WorkoutType::MAPPING.keys.each do |sport_key|
        subclass = sport_key.to_s.camelize.constantize
        expect(subclass.model_name.name).to eq("Workout")
        expect(subclass.model_name.param_key).to eq("workout")
      end
    end
  end

  describe 'sti and details mapping' do
    it 'instantiates each subclass with expected details type' do
      cases = [
        { factory: :running, klass: Running, details_class: Details::Running },
        { factory: :walking, klass: Walking, details_class: Details::Walking },
        { factory: :cycling, klass: Cycling, details_class: Details::Cycling },
        { factory: :swimming, klass: Swimming, details_class: Details::Swimming },
        { factory: :weightlifting, klass: Weightlifting, details_class: Details::Weightlifting },
        { factory: :yoga, klass: Yoga, details_class: Details::Yoga },
        { factory: :soccer, klass: Soccer, details_class: Details::Soccer },
        { factory: :basketball, klass: Basketball, details_class: Details::Basketball },
        { factory: :tennis, klass: Tennis, details_class: Details::Tennis },
        { factory: :martial_arts, klass: MartialArts, details_class: Details::MartialArts },
        { factory: :other, klass: Other, details_class: Details::Base }
      ]

      cases.each do |workout_case|
        workout = create(workout_case[:factory])

        expect(workout).to be_a(workout_case[:klass])
        expect(workout.details).to be_a(workout_case[:details_class])
        expect(workout.workout_type).to eq(workout_case[:factory].to_s)
      end
    end

    it 'enum values match WorkoutType::MAPPING' do
      WorkoutType::MAPPING.each do |key, value|
        expect(Workout.workout_types[key.to_s]).to eq(value)
      end
    end
  end

  describe Running do
    describe "validations" do
      subject { build(:running) }

      it { is_expected.to validate_presence_of(:distance) }
      it { is_expected.to validate_numericality_of(:distance).is_greater_than(0) }
    end

    it "is valid with required distance" do
      running = build(:running, distance: 6.5)
      expect(running).to be_valid
    end

    it "is invalid without distance" do
      running = build(:running)
      running.distance = nil
      expect(running).not_to be_valid
      expect(running.errors[:distance]).to be_present
    end

    it "is invalid with zero distance" do
      running = build(:running)
      running.distance = 0
      expect(running).not_to be_valid
      expect(running.errors[:distance]).to be_present
    end

    it "calculates average pace in details before save" do
      running = build(:running, duration: 30, distance: 5)
      running.details.avg_pace = nil

      running.save!

      expect(running.details.avg_pace).to eq(0.1)
    end
  end

  describe Cycling do
    describe "validations" do
      subject { build(:cycling) }

      it { is_expected.to validate_presence_of(:distance) }
      it { is_expected.to validate_numericality_of(:distance).is_greater_than(0) }
    end

    it "is valid with distance" do
      cycling = build(:cycling, distance: 10.2)
      expect(cycling).to be_valid
    end

    it "is invalid without distance" do
      cycling = build(:cycling)
      cycling.distance = nil
      expect(cycling).not_to be_valid
      expect(cycling.errors[:distance]).to be_present
    end

    it "is invalid with zero distance" do
      cycling = build(:cycling)
      cycling.distance = 0
      expect(cycling).not_to be_valid
      expect(cycling.errors[:distance]).to be_present
    end
  end

  describe Walking do
    describe "validations" do
      subject { build(:walking) }

      it { is_expected.to validate_presence_of(:distance) }
      it { is_expected.to validate_numericality_of(:distance).is_greater_than(0) }
    end

    it "is valid with distance" do
      walking = build(:walking, distance: 3.4)
      expect(walking).to be_valid
    end

    it "is invalid without distance" do
      walking = build(:walking)
      walking.distance = nil
      expect(walking).not_to be_valid
      expect(walking.errors[:distance]).to be_present
    end
  end

  describe Swimming do
    it 'allows nil distance' do
      swimming = build(:swimming)
      swimming.distance = nil

      expect(swimming).to be_valid
    end

    it 'is invalid when distance is zero' do
      swimming = build(:swimming)
      swimming.distance = 0

      expect(swimming).not_to be_valid
      expect(swimming.errors[:distance]).to be_present
    end

    it 'is invalid when details style is not allowed' do
      swimming = build(:swimming)
      swimming.details.style = 'invalid_style'

      expect(swimming.details).not_to be_valid
      expect(swimming.details.errors[:style]).to be_present
      expect(swimming).not_to be_valid
      expect(swimming.errors[:details]).to be_present
    end
  end

  describe Yoga do
    it 'is valid with allowed style' do
      yoga = build(:yoga)
      yoga.details.style = Details::Yoga::VALID_STYLES.first

      expect(yoga).to be_valid
    end

    it 'is invalid with unknown style' do
      yoga = build(:yoga)
      yoga.details.style = 'unknown_style'

      expect(yoga.details).not_to be_valid
      expect(yoga.details.errors[:style]).to be_present
      expect(yoga).not_to be_valid
      expect(yoga.errors[:details]).to be_present
    end
  end

  describe MartialArts do
    it 'is valid with allowed style' do
      martial_arts = build(:martial_arts)
      martial_arts.details.style = Details::MartialArts::VALID_STYLES.first

      expect(martial_arts).to be_valid
    end

    it 'is invalid with unknown style' do
      martial_arts = build(:martial_arts)
      martial_arts.details.style = 'unknown_style'

      expect(martial_arts.details).not_to be_valid
      expect(martial_arts.details.errors[:style]).to be_present
      expect(martial_arts).not_to be_valid
      expect(martial_arts.errors[:details]).to be_present
    end
  end

  describe Basketball do
    it 'is valid with base attributes' do
      basketball = build(:basketball)
      expect(basketball).to be_valid
    end

    it 'stores points and rebounds in details' do
      basketball = build(:basketball)

      expect(basketball.details.points).to be_present
      expect(basketball.details.rebounds).to be_present
    end
  end

  describe Soccer do
    it 'is valid with base attributes' do
      soccer = build(:soccer)
      expect(soccer).to be_valid
    end

    it 'stores goals and position in details' do
      soccer = build(:soccer)

      expect(soccer.details.goals).to be_present
      expect(soccer.details.position).to be_present
    end
  end

  describe Tennis do
    it 'is valid with base attributes' do
      tennis = build(:tennis)
      expect(tennis).to be_valid
    end

    it 'stores sets won and lost in details' do
      tennis = build(:tennis)

      expect(tennis.details.sets_won).to be_present
      expect(tennis.details.sets_lost).to be_present
    end
  end

  describe Weightlifting do
    it 'is valid with base attributes' do
      weightlifting = build(:weightlifting)
      expect(weightlifting).to be_valid
    end

    it 'stores exercises count and volume in details' do
      weightlifting = build(:weightlifting)

      expect(weightlifting.details.exercises_count).to be_present
      expect(weightlifting.details.volume).to be_present
    end
  end

  describe Other do
    it 'is valid with base attributes' do
      other = build(:other)
      expect(other).to be_valid
    end

    it 'stores notes in details' do
      other = build(:other)

      expect(other.details.notes).to be_present
    end
  end
end
