module StringlyEnums
  class PerEnumMetaprogrammer < AbstractMetaprogrammer

    def run!(enum_name, int, aliases)
      enum_name = enum_name
      enum_method = (prefix ? "#{prefix}_#{enum_name}" : enum_name).to_sym
      stored_values = [enum_name, aliases].flatten

      config.available_options[int] = enum_name
      config.allowable_values[int] = stored_values
      config.next_int = (config.available_options.keys.sort.last || 0) + 1

      build_scope(field, enum_method, stored_values) if config.scopes
      build_boolean_getter(field, enum_method, stored_values) if config.boolean_getters
      build_bang_setter(field, enum_method, enum_name) if config.bang_setters
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
      saveable = config.save_after_bang
      new_instance_method("#{method_name}!") do
        send(:"#{field}=", new_value)
        save if saveable
      end
    end

  end
end
