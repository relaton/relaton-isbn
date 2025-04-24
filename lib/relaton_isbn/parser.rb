module RelatonIsbn
  #
  # OpenLibrary document parser.
  #
  class Parser
    ATTRS = %i[fetched title docid link contributor date place].freeze

    def initialize(doc)
      @doc = doc
    end

    def self.parse(doc)
      new(doc).parse
    end

    def parse
      args = ATTRS.each_with_object({}) { |a, h| h[a] = send(a) }
      RelatonBib::BibliographicItem.new(**args)
    end

    private

    def fetched = Date.today.to_s

    def title
      t = [RelatonBib::TypedTitleString.new(content: @doc["data"]["title"], type: "main")]
      if @doc["data"]["subtitle"]
        t << RelatonBib::TypedTitleString.new(content: @doc["data"]["subtitle"], type: "subtitle")
      end
      t
    end

    def docid
      isbn = @doc["details"]["bib_key"].split(":").last
      [RelatonBib::DocumentIdentifier.new(id: isbn, type: "ISBN", primary: true)]
    end

    def link
      [RelatonBib::TypedUri.new(content: @doc["recordURL"], type: "src")]
    end

    def contributor
      create_authors + creaate_publishers
    end

    def create_authors
      @doc["data"]["authors"].map do |a|
        name = RelatonBib::FullName.new completename: RelatonBib::LocalizedString.new(a["name"])
        entity = RelatonBib::Person.new name: name, url: a["url"]
        RelatonBib::ContributionInfo.new entity: entity, role: [{ type: "author" }]
      end
    end

    def creaate_publishers
      @doc["data"]["publishers"].map do |p|
        entity = RelatonBib::Organization.new name: RelatonBib::LocalizedString.new(p["name"])
        RelatonBib::ContributionInfo.new entity: entity, role: [{ type: "publisher" }]
      end
    end

    def date
      @doc["publishDates"].map { RelatonBib::BibliographicDate.new type: "published", on: _1 }
    end

    def place
      @doc["data"]["publish_places"]&.map { RelatonBib::Place.new city: _1["name"] }
    end
  end
end
