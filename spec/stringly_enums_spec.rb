require "spec_helper"

class DummyModel
  attr_accessor :status

  def self.scope(*args)
    @@scopes ||= []
    @@scopes << args
  end

  def self.fetch_scopes
    @@scopes
  end

  def self.reset_scopes
    @@scopes = nil
  end

  def save
    return true
  end

end

describe StringlyEnums do
  let(:dummy_class) { Class.new(DummyModel).tap { |klass| klass.send(:include, StringlyEnums)} }
  subject { dummy_class.new }

  it "has a version number" do
    expect(StringlyEnums::VERSION).not_to be nil
  end

  context 'simple version' do
    before do
      expect(DummyModel).to receive(:scope).at_least(:once) do |field, fn|
        expect([:first, :second, :third, :fourth]).to include(field)
        expect(fn.arity).to be 0
      end

      dummy_class.class_eval do
        stringly_enum status: [:first, :second, :third, :fourth]
      end
    end

    [:first, :second, :third, :fourth].each_with_index do |enum, n|
      it "presents a #{enum}? and #{enum}! method" do
        expect(subject.send :"#{enum}?").to be false
        expect(subject).to respond_to :"#{enum}!"
        subject.send :"#{enum}!"
        expect(subject.status).to eq enum
        expect(subject.send :"#{enum}?").to be true
      end

      it "ensures assignment of status = #{n} returns status == #{enum}" do
        subject.status = nil # good check that this is possible
        expect(subject.status).to eq nil
        subject.status = n
        expect(subject.status).to eq enum
      end

    end
  end


  context 'simple version with config' do

    def self.test_configuration_key(config_key, value, &it_test)
      context "when #{config_key} is #{value.inspect}" do
        before do
          dummy_class.reset_scopes
          dummy_class.class_eval do
            stringly_enum(
              {status: {first: 4, second: 6, third: 8, fourth: 9}},
              { config_key => value }
            )
          end
        end
        it "behaves correctly", &it_test
      end
    end

    def self.test_default_configuration(&it_test)
      context "when using the default config" do
        before do
          dummy_class.reset_scopes
          dummy_class.class_eval do
            stringly_enum(
              {status: {first: 4, second: 6, third: 8, fourth: 9}}
            )
          end
        end
        it "behaves correctly", &it_test
      end
    end


    {
      scopes: [
        ->(_) { expect(subject.class.fetch_scopes).to_not eq nil },
        ->(_) { expect(subject.class.fetch_scopes).to eq nil }
      ],
      boolean_getters: [
        ->(_) { expect(subject).to respond_to :first? },
        ->(_) { expect(subject).to_not respond_to :first? }
      ],
      bang_setters: [
        ->(_) { expect(subject).to respond_to :first! },
        ->(_) { expect(subject).to_not respond_to :first! }
      ],
      save_after_bang: [
        ->(_) { expect(subject).to receive(:save) ; subject.first!},
        ->(_) { expect(subject).to_not receive(:save) ; subject.first!},
      ],
      accessor: [
        ->(_) { subject.status = 9; expect(subject).to be_fourth},
        ->(_) { subject.status = 9; expect(subject).to_not be_fourth},
      ],
      prefix_methods: [
        ->(_) {
          expect(subject).to_not respond_to :first?
          expect(subject).to respond_to :status_first?
        },
        ->(_) {
          expect(subject).to respond_to :first?
          expect(subject).to_not respond_to :status_first?
        },
      ],
    }.each_pair do |config_key, (when_true, when_false)|
      test_configuration_key(config_key, true, &when_true)
      test_configuration_key(config_key, false, &when_false)
    end

    context "allowable_values" do
      test_default_configuration do
        expect(subject.class).to respond_to :status_values
        expect(subject.class.status_values).to eq [:first, :second, :third, :fourth]
      end

      test_configuration_key(:allowable_values_as, "enum_%s_vals_dawg") do
        expect(subject.class).to respond_to :enum_status_vals_dawg
        expect(subject.class.enum_status_vals_dawg).to eq [:first, :second, :third, :fourth]
      end

      test_configuration_key(:allowable_values_as, nil) do
        expect(subject.class).to_not respond_to :status_values
      end

      test_configuration_key(:allowable_values_as, false) do
        expect(subject.class).to_not respond_to :status_values
      end
    end

    # TODO: Test that the following configurations actually return sensible results!
    context "available_options" do
      test_default_configuration do
        expect(subject.class).to respond_to :status_options
        expect(subject.class.status_options).to eq [:first, :second, :third, :fourth]
      end

      test_configuration_key(:available_options_as, "enum_%s_opts_dawg") do
        expect(subject.class).to respond_to :enum_status_opts_dawg
        expect(subject.class.enum_status_opts_dawg).to eq [:first, :second, :third, :fourth]
      end

      test_configuration_key(:available_options_as, nil) do
        expect(subject.class).to_not respond_to :status_options
      end

      test_configuration_key(:available_options_as, false) do
        expect(subject.class).to_not respond_to :status_options
      end
    end

    context "available_mappings" do
      test_default_configuration do
        expect(subject.class).to respond_to :status_mappings
        expect(subject.class.status_mappings).to eq(4=>:first, 6=>:second, 8=>:third, 9=>:fourth)
      end

      test_configuration_key(:available_mappings_as, "enum_%s_mapz") do
        expect(subject.class).to respond_to :enum_status_mapz
        expect(subject.class.enum_status_mapz).to eq(4=>:first, 6=>:second, 8=>:third, 9=>:fourth)
      end

      test_configuration_key(:available_mappings_as, nil) do
        expect(subject.class).to_not respond_to :status_mappings
      end

      test_configuration_key(:available_mappings_as, false) do
        expect(subject.class).to_not respond_to :status_mappings
      end
    end

    context "multi-status" do
      test_default_configuration do
        expect { subject.status = [:first, 8] }.to raise StringlyEnums::ConfigurationError
      end

      test_configuration_key(:multi, true) do
        subject.status = 1
        expect(subject.status).to eq [:first]

        subject.fourth!
        expect(subject.status).to eq [:first, :fourth]

        expect { subject.status = [:first, 8] }.to_not raise StringlyEnums::ConfigurationError
        expect(subject.status).to eq [:first, :third]
      end

      test_configuration_key(:multi, nil) do
        expect { subject.status = [:first, 8] }.to raise StringlyEnums::ConfigurationError
      end

      test_configuration_key(:multi, false) do
        expect { subject.status = [:first, 8] }.to raise StringlyEnums::ConfigurationError
      end
    end
  end


  context 'explicitly numbered enums (n squared)' do
    before do
      dummy_class.class_eval do
        stringly_enum status: {first: 0, second: 1, third: 4, fourth: 9 }
      end
    end

    [:first, :second, :third, :fourth].each_with_index do |enum, n|
      it "presents a #{enum}? and #{enum}! method" do
        expect(subject.send :"#{enum}?").to be false
        expect(subject).to respond_to :"#{enum}!"
        subject.send :"#{enum}!"
        expect(subject.status).to eq enum
        expect(subject.send :"#{enum}?").to be true
      end

      it "ensures assignment of status = #{n**2} returns status == #{enum}" do
        subject.status = nil # good check that this is possible
        expect(subject.status).to eq nil
        subject.status = n ** 2
        expect(subject.status).to eq enum
      end
    end
  end

  context 'block-defined enums' do
    before do
      dummy_class.class_eval do
        stringly_enum :status do |m, config|
          m.first int: 0
          m.second int: 1, stored_as: %w[2nd sec deuxieme]
          m.third int: 3, stored_as: 'therd'
          m.fourth # int will be 4, stored as 'fourth'
        end
      end
    end

    it "allows basic stored value" do
      expect(subject).to_not be_first
      subject.status = :first
      expect(subject.first?).to be true
      subject.status = nil
      expect(subject.first?).to be false
      subject.first!
      expect(subject.first?).to be true
    end

    it "allows aliases" do
      expect(subject).to_not be_second
      subject.status = '2nd'
      expect(subject.second?).to be true
      subject.status = 'deuxieme'
      expect(subject.second?).to be true
      subject.status = nil
      expect(subject.second?).to be false
      subject.second!
      expect(subject.second?).to be true
      expect(subject.status).to eq :second
    end

    it "allows aliases without arrays" do
      expect(subject).to_not be_third
      subject.status = 'therd'
      expect(subject.third?).to be true
    end

    it "auto-increments unspecified enum ints" do
      expect(subject).to_not be_fourth
      subject.status = 4
      expect(subject.fourth?).to be true
    end
  end

end
