module StringlyEnums
  class AbstractMetaprogrammer
    def initialize(factory)
      @factory = factory
    end

    def run!(enum_name, int, aliases)
      raise "Override me!"
    end

    private def klass; @factory.klass; end
    private def config; @factory.config; end
    private def prefix; @factory.prefix; end
    private def field; @factory.field; end


    private def new_instance_method(name, &block)
      reopen { define_method name, &block }
    end

    private def new_class_method(name, &block)
      reopen { define_singleton_method name, &block }
    end

    private def reopen(&block)
      klass.instance_eval &block
    end
  end
end
