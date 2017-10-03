require 'json'

module StringlyEnums

  class PerFieldMetaprogrammer < AbstractMetaprogrammer

    def run!
      build_mappings if config.available_mappings_as
      build_available_options if config.available_options_as
      build_allowable_values if config.allowable_values_as
      build_accessor if config.accessor
    end

    private def build_available_options
      method_name = config.available_options_as % field
      options = config.available_options.values.flatten
      new_class_method(method_name) { options.dup }
    end

    private def build_mappings
      method_name = config.available_mappings_as % field
      options = config.available_options
      new_class_method(method_name) { options.dup }
    end

    private def build_allowable_values
      method_name = config.allowable_values_as % field
      values = config.allowable_values.values.flatten
      new_class_method(method_name) { values.dup }
    end

    private def build_accessor
      int_translator = config.available_options
      if config.multi
        new_instance_method(:"#{field}=") do |items|
          items = [items] unless items.is_a?(Array)
          items.map! {|item| (item.respond_to?(:to_i) && item.to_i == item) ? int_translator[item] : item }
          super(StringlyEnums::MultiSerializer.serialize(items))
        end

        new_instance_method(field) do
          StringlyEnums::MultiSerializer.parse(super()).map(&:to_sym)
        end
      else
        new_instance_method(:"#{field}=") do |item|
          raise StringlyEnums::ConfigurationError, "Cannot assign array to an enum unless enum configured with config.multi = true" if item.is_a?(Array)
          item = int_translator[item] if item.respond_to?(:to_i) && item.to_i == item
          super(item)
        end
      end
    end
  end
end
