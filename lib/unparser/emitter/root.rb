module Unparser
  class Emitter
    class Root < self
      include Concord::Public.new(:buffer)
    end # Root
  end # Emitter
end # Unparser
