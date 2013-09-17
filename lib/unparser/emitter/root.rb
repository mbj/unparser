module Unparser
  class Emitter
    # Root emitter a special case
    class Root < self
      include Concord::Public.new(:buffer, :comments)
    end # Root
  end # Emitter
end # Unparser
