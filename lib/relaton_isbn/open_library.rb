module RelatonIsbn
  #
  # Search ISBN in Openlibrary.
  #
  module OpenLibrary
    extend self

    ENDPOINT = "http://openlibrary.org/api/volumes/brief/isbn/".freeze

    def get(ref, _date = nil, _opts = {})
      Util.warn "(#{ref}) Fetching from OpenLibrary ..."

      resp = request_api ref
      unless resp
        Util.warn "(#{ref}) Not found."
        return
      end

      bib = Parser.parse resp
      Util.warn "(#{ref}) Found: `#{bib.docidentifier.first.id}`"
      bib
    end

    def request_api(ref)
      /ISBN\s*(?<isbn>\w+)/ =~ ref
      return unless isbn

      uri = URI "#{ENDPOINT}#{isbn}.json"
      response = Net::HTTP.get_response uri
      return unless response.is_a? Net::HTTPSuccess

      data = JSON.parse response.body
      return unless data["records"]&.any?

      data["records"].first.last
    end
  end
end
