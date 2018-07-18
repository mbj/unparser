module Unparser
  class Emitter
    # Namespace class for meta emitters
    class Meta < self
      include Terminated

      handle(:__FILE__, :__LINE__)

      def dispatch
        write(node.type.to_s) # (e.g. literally write '__FILE__' or '__LINE__')
      end
    end # Meta
  end # Emitter
end # Unparser
