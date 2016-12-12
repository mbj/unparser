module Unparser
  # Break `enum` into chunks by iterating over it and yielding pairs of adjacent
  # elements. If the provided block returns a truthy value, start a new chunk.
  #
  # @param [Enumerable] enum
  #
  # @return [Array]
  #
  # @api private
  #
  def self.chunk_by(enum)
    chunk = prev = nil
    enum.each_with_object([]) do |obj, chunks|
      if !chunk || yield(prev, obj)
        chunk = [obj]
        chunks << chunk
      else
        chunk << obj
      end
      prev = obj
    end
  end
end
