module StringlyEnums

  class ModelMaker < BasicObject
    def initialize(klass, configurator, field)
      @klass = klass
      @config = configurator
      @field = field
      @builder = MetaprogrammingFactory.new(@klass, @config, @field)
    end

    def method_missing(meth, **args, &block)
      StringlyEnums.raise_backwards_error if args[:int] && args[:int] < @config.next_int
      aliases = [args[:stored_as]].flatten.uniq.compact
      next_int = args[:int] || @config.next_int
      @builder.add(meth, next_int, aliases)
    end

    def finish!
      @builder.finish!
    end

  end
end
