module StringlyEnums
  class MetaprogrammingFactory
    attr_reader :klass, :config, :field, :prefix

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

      PerEnumMetaprogrammer.new(self).run!(enum_name, int, aliases)
    end

    def finish!
      PerFieldMetaprogrammer.new(self).run!
    end

  end
end
