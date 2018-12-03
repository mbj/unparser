# frozen_string_literal: true

module Unparser
  class Emitter
    # Namespace class for meta emitters
    class Meta < self
      include Terminated

      handle(:__ENCODING__, :__FILE__, :__LINE__)

      def dispatch
        write(node.type.to_s)
      end
    end # Meta
  end # Emitter
end # Unparser
