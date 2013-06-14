module Unparser
  class Emitter
    Root = ::Class.new(self) do
      def initialize(); end
    end.send(:new)
  end
end
