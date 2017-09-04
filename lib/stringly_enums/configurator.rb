module StringlyEnums

  class Configurator
    METAPROGRAMMING = [:scopes, :boolean_getters, :bang_setters, :save_after_bang, :accessor]
    TWEAKS = [:prefix_methods, :next_int]
    attr_accessor *(METAPROGRAMMING + TWEAKS)

    def initialize
      enable_all_metaprogramming!
      @next_int = 0
      if block_given?
        yield self
      end
    end

    def enable_all_metaprogramming!
      METAPROGRAMMING.each do |attr|
        send(:"#{attr}=", true)
      end
    end

    def disable_all_metaprogramming!
      METAPROGRAMMING.each do |attr, value|
        send(:"#{attr}=", value)
      end
    end

    def merge!(options)
      options.each_pair do |attr, value|
        send(:"#{attr}=", value)
      end
    end
  end

end
