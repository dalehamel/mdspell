require_relative 'mdspell/version'
require_relative 'mdspell/cli'
require_relative 'mdspell/configuration'
require_relative 'mdspell/spell_checker'
require_relative 'mdspell/text_line'
require_relative 'mdspell/typo'

require 'rainbow'

# This module holds all the MdSpell code (except mdspell shell command).
module MdSpell
  extend self

  def run(argv)
    cli = MdSpell::CLI.new
    cli.run argv
    cli.files.each(&method(:check_file))

    exit_if_had_errors
  end


  def check_file(filename, **kwargs)
    text = if filename == '-'
      STDIN.read
    else
      File.read(filename)
    end

    configure(**kwargs)
    spell_check(text, filename)
  end

  def check_string(string, **kwargs)
    configure(**kwargs)
    spell_check(string, '<string>')
  end

private

  def configure(**kwargs)
    MdSpell::Configuration.reset unless kwargs.empty?
    MdSpell::Configuration.load!(kwargs)
  end

  def spell_check(string, source)
    verbose "Spell-checking #{source}..."

    spell_checker = SpellChecker.new(string)

    spell_checker.typos.each do |typo|
      error "#{source}:#{typo.line.location}: #{typo.word}"
    end
  end

  def verbose(str)
    puts str if Configuration[:verbose]
  end

  def error(str)
    @had_errors = true
    puts Rainbow(str).red
  end

  def exit_if_had_errors
    if @had_errors
      # If exit will be suppressed (line in tests or using at_exit), we need to clean @had_errors
      @had_errors = false
      exit(1)
    end
  end
end
