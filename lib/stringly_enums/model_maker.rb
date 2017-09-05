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

    def self.add(klass, config, field, method, int = config.next_int, aliases = [])
      StringlyEnums.raise_backwards_error if int < config.next_int
      config.next_int = int + 1
      field = field.to_sym
      prefix = (config.prefix_methods == true ? field : config.prefix_methods) if config.prefix_methods
      method = "#{prefix}_#{method}" if prefix
      method = method.to_sym
      stored_values = [method, aliases].flatten

      klass.instance_eval do
        scope field, -> { where(field: stored_values) } if config.scopes

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

        # Not particularly efficient, if it even works...
        if config.accessor && new.respond_to?(:"#{field}=") # Subverts rails lazy-loader 
          old_method = instance_method(:"#{field}=")
          define_method(:"#{field}=") do |item|
            return old_method.bind(self).call(method) if item == int
            old_method.bind(self).call(item)
          end
        end

      end


    end
  end
end
