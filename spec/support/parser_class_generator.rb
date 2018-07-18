module ParserClassGenerator
  def self.generate_with_options(base_parser_class, builder_options)
    # This builds a dynamic subclass of the base_parser_class (e.g. Parser::Ruby23)
    # and overrides the default_parser method to return a parser whose builder
    # has various options set.
    #
    # Currently the only builder option is :emit_file_line_as_literals

    Class.new(base_parser_class) do
      define_singleton_method(:default_parser) do |*args|
        super(*args).tap do |parser|
          parser.builder.emit_file_line_as_literals = builder_options[:emit_file_line_as_literals]
        end
      end

      define_singleton_method(:inspect) do
        "#{base_parser_class.inspect} with builder options: #{builder_options.inspect}"
      end
    end
  end
end
