module StringlyEnums
  def self.raise_backwards_error
    raise "Cannot go backwards; please define all ints to be positive and higher than the previous ones"
  end

  class ModelMaker < BasicObject
    def initialize(klass, field, configurator)
      @klass = klass
      @field = field
      @config = configurator
    end

    def method_missing(meth, **args, &block)
      StringlyEnums.raise_backwards_error if args[:int] && args[:int] < @config.next_int
      aliases = [args[:stored_as]].flatten.uniq.compact
      next_int = args[:int] || @config.next_int
      ModelMaker.add @klass, @config, @field, meth, next_int, aliases
    end

    def self.post_build(klass, config, field)
      klass.instance_eval do

        if config.available_mappings_as
          available_mappings_method_name = config.available_mappings_as % field
          define_singleton_method available_mappings_method_name do
            config.available_options
          end
        end

        if config.available_options_as
          available_options_method_name = config.available_options_as % field
          define_singleton_method available_options_method_name do
            config.available_options.values.flatten
          end
        end

        if config.allowable_values_as
          allowable_values_method_name = config.allowable_values_as % field
          define_singleton_method allowable_values_method_name do
            config.allowable_values.values.flatten
          end
        end


        if config.accessor
          define_method(:"#{field}=") do |item|
            return super(item) unless item.respond_to?(:to_i) && item.to_i == item
            super(config.available_options[item])
          end
        end
      end


    end

    def self.add(klass, config, field, method, int = config.next_int, aliases = [])
      StringlyEnums.raise_backwards_error if int < config.next_int
      config.next_int = int + 1
      field = field.to_sym
      prefix = (config.prefix_methods == true ? field : config.prefix_methods) if config.prefix_methods
      method = "#{prefix}_#{method}" if prefix
      method = method.to_sym
      stored_values = [method, aliases].flatten
      config.available_options[int] = method
      config.allowable_values[int] = stored_values

      klass.instance_eval do
        scope method, -> { where(field => stored_values) } if config.scopes

        if config.boolean_getters
          define_method "#{method}?" do
            stored_values.include? self.send(field)
          end
        end

        if config.bang_setters
          define_method "#{method}!" do
            self.send(:"#{field}=", method)
            save if config.save_after_bang
          end
        end

      end


    end
  end
end
