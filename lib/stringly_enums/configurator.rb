module StringlyEnums

  class Configurator
    METAPROGRAMMING = [:scopes, :allowable_values_as, :available_options_as, :available_mappings_as, :boolean_getters, :bang_setters, :save_after_bang, :accessor]
    TWEAKS = [:prefix_methods, :next_int, :allowable_values, :available_options, :multi]
    attr_accessor(*(METAPROGRAMMING + TWEAKS))

    DEFAULTS = {allowable_values_as: "%s_values", available_options_as: "%s_options", available_mappings_as: "%s_mappings"}

    def initialize
      enable_all_metaprogramming!
      @next_int = 0
      @allowable_values = {}
      @available_options = {}
      if block_given?
        yield self
      end
    end

    def enable_all_metaprogramming!
      METAPROGRAMMING.each do |attr|
        send(:"#{attr}=", DEFAULTS.fetch(attr, true))
      end
    end

    def disable_all_metaprogramming!
      METAPROGRAMMING.each do |attr|
        send(:"#{attr}=", false)
      end
    end

    def merge!(options)
      options.each_pair do |attr, value|
        send(:"#{attr}=", value)
      end
    end
  end

end
