module Unparser
  # DSL to help defining emitters
  module DSL

  private

    # Define remaining children
    #
    # @param [Enumerable<Symbol>] names
    #
    # @return [undefined]
    #
    # @api private
    #
    def define_remaining_children(names)
      range = names.length..-1
      define_method(:remaining_children) do
        children[range]
      end
      private :remaining_children
    end

    # Define named child
    #
    # @param [Symbol] name
    # @param [Fixnum] index
    #
    # @return [undefined]
    #
    # @api private
    #
    def define_child(name, index)
      define_method(name) do
        children.at(index)
      end
      private name
    end

    # Define a group of children
    #
    # @param [Symbol] name
    # @param [Range] range
    #
    # @return [undefined]
    #
    # @pai private
    #
    def define_group(name, range)
      define_method(name) do
        children[range]
      end
      private(name)
      memoize(name)
    end

    # Create name helpers
    #
    # @return [undefined]
    #
    # @api private
    #
    def children(*names)
      define_remaining_children(names)

      names.each_with_index do |name, index|
        define_child(name, index)
      end
    end

  end # DSL
end # Unparser
