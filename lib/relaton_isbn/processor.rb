require "relaton/processor"

module RelatonIsbn
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_isbn
      @prefix = "ISBN"
      @defaultprefix = /^ISBN\s/
      @idtype = "ISBN"
      @datasets = %w[]
    end

    # @param code [String]
    # @param date [String, nil] year
    # @param opts [Hash]
    # @return [RelatonBib::BibliographicItem]
    def get(code, date, opts)
      ::RelatonIsbn::OpenLibrary.get(code, date, opts)
    end

    #
    # @param [String] source source name (bipm-data-outcomes, bipm-si-brochure,
    #   rawdata-bipm-metrologia)
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    # def fetch_data(source, opts)
    #   DataFetcher.fetch(source, **opts)
    # end

    # @param xml [String]
    # @return [RelatonBib::BibliographicItem]
    def from_xml(xml)
      ::RelatonBib::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonBib::BibliographicItem]
    def hash_to_bib(hash)
      ::RelatonBib::BibliographicItem.from_hash hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonIsbn.grammar_hash
    end

    #
    # Remove index file
    #
    # def remove_index_file
    # end
  end
end
