module StringlyEnums
  class MetaprogrammingFactory
    def initialize(klass, config, field)
      @klass = klass
      @config = config
      @field = field.to_sym
      @prefix = (@config.prefix_methods == true ? @field : @config.prefix_methods) if @config.prefix_methods
    end

    def add_all(enumerables)
      if enumerables.is_a? Hash
        enumerables.each_pair {|enum_name, int| add enum_name, int }
      elsif enumerables.is_a? Array
        enumerables.each { |enum_name| add enum_name }
      else
        raise ArgumentError, 'stringly_enums arguments should be ordered `{fieldname: enums}, (opt) @config` or `:fieldname, &block`'
      end
    end

    def add(enum_name, int = @config.next_int, aliases = [])
      StringlyEnums.int_clash!(enum_name, int, @config) if @config.available_options[int]

      @enum_name = enum_name
      @enum_method = (@prefix ? "#{@prefix}_#{enum_name}" : enum_name).to_sym
      @int = int
      @aliases = aliases
      @stored_values = [@enum_name, @aliases].flatten

      @config.available_options[int] = @enum_name
      @config.allowable_values[int] = @stored_values
      @config.next_int = (@config.available_options.keys.sort.last || 0) + 1

      build_scope(@field, @enum_method, @stored_values) if @config.scopes
      build_boolean_getter(@field, @enum_method, @stored_values) if @config.boolean_getters
      build_bang_setter(@field, @enum_method, @enum_name) if @config.bang_setters
    end

    def finish!
      build_mappings if @config.available_mappings_as
      build_available_options if @config.available_options_as
      build_allowable_values if @config.allowable_values_as
      build_accessor if @config.accessor
    end

    private def build_available_options
      method_name = @config.available_options_as % @field
      options = @config.available_options.values.flatten
      new_class_method(method_name) { options.dup }
    end

    private def build_mappings
      method_name = @config.available_mappings_as % @field
      options = @config.available_options
      new_class_method(method_name) { options.dup }
    end

    private def build_allowable_values
      method_name = @config.allowable_values_as % @field
      values = @config.allowable_values.values.flatten
      new_class_method(method_name) { values.dup }
    end

    private def build_accessor
      int_translator = @config.available_options
      new_instance_method(:"#{@field}=") do |item|
        item = int_translator[item] if item.respond_to?(:to_i) && item.to_i == item
        super(item)
      end
    end

    private def build_scope(field, method_name, stored_values)
      reopen do
        scope method_name, -> { where(field => stored_values) }
      end
    end

    private def build_boolean_getter(field, method_name, stored_values)
      new_instance_method("#{method_name}?") do
        stored_values.include? send(field)
      end
    end

    private def build_bang_setter(field, method_name, new_value)
      saveable = @config.save_after_bang
      new_instance_method("#{method_name}!") do
        send(:"#{field}=", new_value)
        save if saveable
      end
    end

    private def new_instance_method(name, &block)
      reopen { define_method name, &block }
    end

    private def new_class_method(name, &block)
      reopen { define_singleton_method name, &block }
    end

    private def reopen(&block)
      @klass.instance_eval &block
    end
  end
end
