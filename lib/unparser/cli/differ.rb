# encoding: utf-8

module Unparser
  class CLI
    # Unparser CLI specific differ
    class Differ < Mutant::Differ
      include Procto.call(:colorized_diff)

      # Return source diff
      #
      # FIXME: Multiple diffs get screwed up!
      #
      # @return [String]
      #   if there is a diff
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def diff
        diffs.map do |piece|
          Diff::LCS::Hunk.new(old, new, piece, max_length, old.length - new.length).diff(:unified) << "\n"
        end.join
      end
      memoize :diff

    end # Differ
  end # CLI
end # Unparser
