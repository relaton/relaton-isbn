describe RelatonIsbn::Parser do
  let (:doc) do
    {
      "publishDates" => ["2008"],
      "recordURL" => "https://openlibrary.org/books/OL21119585M/Introduction_to_the_theory",
      "data" => {
        "title" => "Title",
        "subtitle" => "Subtitle",
        "authors" => [{ "name" => "James Arvo", "url" => "https://openlibrary.org/authors/OL21119585M/James_Arvo" }],
        "publishers" => [{ "name" => "AP Professional" }],
        "publish_places" => [{ "name" => "Boston" }, { "name" => "London" }],
      },
      "details" => { "bib_key" => "ISBN:9780120644810" },
    }
  end

  subject { described_class.new doc }

  it "initialize" do
    expect(subject.instance_variable_get(:@doc)).to be doc
  end

  it "create parser & parse" do
    parser = double "parser"
    expect(parser).to receive(:parse).and_return :bib
    expect(described_class).to receive(:new).with(:doc).and_return parser
    expect(described_class.parse(:doc)).to eq :bib
  end

  context "instance methods" do
    it "#parse" do
      parser = described_class.new :doc
      expect(parser).to receive(:title).and_return :title
      expect(parser).to receive(:docid).and_return :docid
      expect(parser).to receive(:link).and_return :link
      expect(parser).to receive(:contributor).and_return :contributor
      expect(parser).to receive(:date).and_return :date
      expect(parser).to receive(:place).and_return :place
      expect(RelatonBib::BibliographicItem).to receive(:new).with(
        title: :title, docid: :docid, link: :link, contributor: :contributor, date: :date, place: :place,
      ).and_return :bib
      expect(parser.parse).to eq :bib
    end

    it "#title" do
      title = subject.send :title
      expect(title).to be_instance_of Array
      expect(title.size).to eq 2
      expect(title.first).to be_instance_of RelatonBib::TypedTitleString
      expect(title.first.to_s).to eq "Title"
      expect(title.first.type).to eq "main"
      expect(title.last).to be_instance_of RelatonBib::TypedTitleString
      expect(title.last.to_s).to eq "Subtitle"
      expect(title.last.type).to eq "subtitle"
    end

    it "#docid" do
      docid = subject.send :docid
      expect(docid).to be_instance_of Array
      expect(docid.size).to eq 1
      expect(docid.first).to be_instance_of RelatonBib::DocumentIdentifier
      expect(docid.first.id).to eq "9780120644810"
      expect(docid.first.type).to eq "ISBN"
      expect(docid.first.primary).to be true
    end

    it "#link" do
      link = subject.send :link
      expect(link).to be_instance_of Array
      expect(link.size).to eq 1
      expect(link.first).to be_instance_of RelatonBib::TypedUri
      expect(link.first.content.to_s).to eq "https://openlibrary.org/books/OL21119585M/Introduction_to_the_theory"
      expect(link.first.type).to eq "src"
    end

    it "#contributor" do
      expect(subject).to receive(:create_authors).and_return [:authors]
      expect(subject).to receive(:creaate_publishers).and_return [:publishers]
      expect(subject.send(:contributor)).to eq %i[authors publishers]
    end

    it "#create_authors" do
      authors = subject.send :contributor
      expect(authors).to be_instance_of Array
      expect(authors.size).to eq 2
      expect(authors.first).to be_instance_of RelatonBib::Contributor
      expect(authors.first.entity).to be_instance_of RelatonBib::Person
      expect(authors.first.entity.name.completename.content).to eq "James Arvo"
      expect(authors.first.entity.url.to_s).to eq "https://openlibrary.org/authors/OL21119585M/James_Arvo"
      expect(authors.first.role).to be_instance_of Array
      expect(authors.first.role.first.type).to eq "author"
    end

    it "#date" do
      dates = subject.send :date
      expect(dates).to be_instance_of Array
      expect(dates.size).to eq 1
      expect(dates.first).to be_instance_of RelatonBib::BibliographicDate
      expect(dates.first.type).to eq "published"
      expect(dates.first.on).to eq "2008"
    end

    it "#place" do
      places = subject.send :place
      expect(places).to be_instance_of Array
      expect(places.size).to eq 2
      expect(places.first).to be_instance_of RelatonBib::Place
      expect(places.first.city).to eq "Boston"
      expect(places.last.city).to eq "London"
    end
  end
end
