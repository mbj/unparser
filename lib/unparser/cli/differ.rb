# encoding: utf-8

module Unparser
  class CLI
    # Class to create diffs from source code
    class Differ
      include Adamantium::Flat, Concord.new(:old, :new), Procto.call(:colorized_diff)

      # Return source diff
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

      # Return colorized source diff
      #
      # @return [String]
      #   if there is a diff
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def colorized_diff
        diff.lines.map do |line|
          self.class.colorize_line(line)
        end.join
      end
      memoize :colorized_diff

      # Return new object
      #
      # @param [String] old
      # @param [String] new
      #
      # @return [Differ]
      #
      # @api private
      #
      def self.build(old, new)
        new(lines(old), lines(new))
      end

      # Break up source into lines
      #
      # @param [String] source
      #
      # @return [Array<String>]
      #
      # @api private
      #
      def self.lines(source)
        source.lines.map { |line| line.chomp }
      end
      private_class_method :lines

    private

      # Return diffs
      #
      # @return [Array<Array>]
      #
      # @api private
      #
      def diffs
        Diff::LCS.diff(old, new)
      end
      memoize :diffs

      # Return max length
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def max_length
        [old, new].map(&:length).max
      end

      # Return colorized diff line
      #
      # @param [String] line
      #
      # @return [String]
      #
      # @api private
      #
      def self.colorize_line(line)
        case line[0]
        when '+'
          Color::GREEN
        when '-'
          Color::RED
        else
          Color::NONE
        end.format(line)
      end

    end # CLI
  end # Differ
end # Unparser
