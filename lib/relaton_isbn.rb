require "net/http"
require "relaton_bib"
require_relative "relaton_isbn/version"
require_relative "relaton_isbn/util"
require_relative "relaton_isbn/isbn"
require_relative "relaton_isbn/parser"
require_relative "relaton_isbn/open_library"

module RelatonIsbn
  module_function

  # Returns hash of XML reammar
  # @return [String]
  def grammar_hash
    Digest::MD5.hexdigest RelatonIsbn::VERSION + RelatonBib::VERSION # grammars
  end
end
