require "stringly_enums/version"
require "stringly_enums/configurator"
require "stringly_enums/model_maker"

module StringlyEnums
  class Main
    class << self
      def build_config
        (@config ||= Configurator.new).dup
      end

      def build(klass, enumerable_fields, options, &block)
        config = build_config
        config.merge!(options)
        if block
          block.call ModelMaker.new(klass, enumerable_fields, config), config
        else
          enumerable_fields.each_pair do |field_name, enumerables|
            if enumerables.is_a? Hash
              enumerables.each_pair do |enum_name, int|
                ModelMaker.add klass, config, field_name, enum_name, int
              end
            elsif enumerables.is_a? Array
              enumerables.each do |enum_name|
                ModelMaker.add klass, config, field_name, enum_name
              end
            else
              raise ArgumentError, "stringly_enums arguments should be ordered `{fieldname: enums}, (opt) config` or `:fieldname, &block`"
            end
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
