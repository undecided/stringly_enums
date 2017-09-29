require "stringly_enums/version"
require "stringly_enums/configurator"
require "stringly_enums/abstract_metaprogrammer"
require "stringly_enums/per_field_metaprogrammer"
require "stringly_enums/per_enum_metaprogrammer"
require "stringly_enums/metaprogramming_factory"
require "stringly_enums/model_maker"

module StringlyEnums
  class ConfigurationError < StandardError; end
  class IntegerClashError < StandardError; end

  def self.int_clash!(int, enum, config)
    redefining = config.available_options[int].inspect
    raise IntegerClashError, "The integer #{int} has already been used" \
                             "- already defined as #{redefining}, " \
                             "could not redefine as #{enum})"
  end

  class Main
    class << self
      def stored_config
        nil # use when we pre-configure
      end

      def build_config
        (stored_config || Configurator.new).dup
      end

      def build(klass, enumerable_fields, options, &block)
        config = build_config
        config.merge!(options)
        if block
          builder = ModelMaker.new(klass, config, enumerable_fields)
          block.call builder, config
          builder.finish!
        else
          enumerable_fields.each_pair do |field_name, enumerables|
            builder = MetaprogrammingFactory.new(klass, config, field_name)
            builder.add_all(enumerables)
            builder.finish!
          end
        end
      end

    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def stringly_enum(enumerable_fields = nil, options = {}, &block)
      Main.build self, enumerable_fields, options, &block
    end
  end
end
