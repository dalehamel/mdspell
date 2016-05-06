require_relative 'configuration'

require 'kramdown'
require 'ffi/aspell'

module MdSpell
  # A class for finding spelling errors in document.
  class SpellChecker
    # A Kramdown::Document object containing the parsed markdown document.
    attr_reader :document

    # Create a new instance from specified file.
    # @param text [String] a name of file to load.
    def initialize(text)
      @document = Kramdown::Document.new(text, input: 'GFM')
    end

    # Returns found spelling errors.
    def typos
      results = []

      FFI::Aspell::Speller.open(Configuration[:language]) do |speller|
        TextLine.scan(document).each do |line|
          line.words.each do |word|
            unless speller.correct? word
              results << Typo.new(line, word, speller.suggestions(word))
            end
          end
        end
      end

      results
    end
  end
end
