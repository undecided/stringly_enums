module StringlyEnums
  class MultiSerializer
    LCHAR = RCHAR = ":"
    WRAPPER = "#{LCHAR}X#{RCHAR}"
    UNWRAPPER = /#{LCHAR}([^#{Regexp.escape(LCHAR)}#{Regexp.escape(RCHAR)}]+)#{RCHAR}/

    class << self
      def parse(str)
        return [] if str.nil? || str.to_s.strip == ''
        return [str] unless str[UNWRAPPER]
        str.scan(UNWRAPPER).flatten.map(&:to_sym)
      end

      def wrap(val)
        WRAPPER.sub('X', val.to_s)
      end

      def serialize(values)
        values.map { |v| wrap v }.join('')
      end

      def or_based_search_sql(field_name, values)
        captures = values.map { |val| wrap val }
        sections = ["#{field_name} LIKE ?"] * values.length
        [sections.join(" OR "), captures]
      end
    end
  end
end
