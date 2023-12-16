RSpec.describe RelatonIsbn do
  it "has a version number" do
    expect(RelatonIsbn::VERSION).not_to be nil
  end

  it "returns grammar hash" do
    gh = RelatonIsbn.grammar_hash
    expect(gh).to be_instance_of String
    expect(gh.length).to eq 32
  end

  context "get" do
    it "success", vcr: "success" do
      bib = RelatonIsbn::OpenLibrary.get "ISBN 9780120644810"
      expect(bib).to be_instance_of RelatonBib::BibliographicItem
      expect(bib.docidentifier.first.id).to eq "9780120644810"
    end
  end
end
