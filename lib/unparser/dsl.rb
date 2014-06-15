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
      define_method(:remaining_children) do
        children[names.length..-1]
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
    # @param [Fixum] first
    #   the start index
    # @param [Fixum] last
    #   the optionally relative end index
    #
    # @return [undefined]
    #
    # @pai private
    #
    def define_group(name, first, last)
      range = first .. last
      define_method(name) do
        children[range]
      end
      memoize name

      indice_method_name = "#{name}_indices"
      define_method(indice_method_name) do
        effective_last = if last < 0
                           children.length + last
                         else
                           last
                         end
        first.start.upto(effective_last).to_a
      end
      memoize indice_method_name
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
