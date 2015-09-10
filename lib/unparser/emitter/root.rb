module Unparser
  class Emitter
    # Root emitter a special case
    class Root < self
      include Concord::Public.new(:node, :buffer, :comments)
      include LocalVariableRoot
    end # Root
  end # Emitter
end # Unparser
