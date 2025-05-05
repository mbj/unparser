# frozen_string_literal: true

module Unparser
  module Writer
    class Array
      include Writer, Adamantium

      MAP = {
        dsym: '%I',
        sym:  '%i',
        dstr: '%W',
        str:  '%w'
      }.freeze
      private_constant(*constants(false))

      def emit_compact # rubocop:disable Metrics/AbcSize
        children_generic_type = array_elements_generic_type

        write(MAP.fetch(children_generic_type))

        parentheses('[', ']') do
          delimited(children, ' ') do |child|
            if n_sym?(child) || n_str?(child)
              write(Util.one(child.children).to_s)
            else
              write('#{')
              emitter(unwrap_single_begin(Util.one(child.children))).write_to_buffer
              write('}')
            end
          end
        end
      end

      private

      def array_elements_generic_type
        children_types = children.to_set(&:type)

        if children_types == Set[:sym, :dsym]
          :dsym
        elsif children_types == Set[:str, :dstr]
          :dstr
        elsif children_types == Set[]
          :sym
        else
          Util.one(children_types.to_a)
        end
      end
    end # Array
  end # Writer
end # Unparser
