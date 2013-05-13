module Unparser
  class Emitter
    class Singleton < self

      handle :self, :true, :false, :nil

      def self.emit(node, buffer)
        buffer.append(node.type.to_s)
      end
    end
  end
end
