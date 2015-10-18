
require 'spec_helper'

describe Definition do
  #it { should belong_to :word }
  #it { should have_many(:word_links).dependent(:destroy) }
  #it { should have_many :words.through(:word_links) }

  context "reading from csv" do
    it "loads definitions from a file" do
      require 'zlib'

      file_name = File.join 'tmp', '_definition.csv.gz'
      begin
        Zlib::GzipWriter.open file_name do |gz|
          %w(nice,0,nasty
             nice,1,good
             nice,2,pleasant,agreeable
             nice,3,pleasing).each {|line| gz.puts line }
        end
        Definition.load_db file_name, false
        words = Definition.by_word('nice').words.collect &:name
        expect(words).to eq %w(nasty good pleasant agreeable pleasing)
      ensure
        File.unlink file_name if File.file? file_name
      end
    end
  end

  context "(root word)" do
    let(:definition) { Definition.for_word 'pantaloons' }

    it "is created from a string" do
      expect(definition).to be_persisted
      expect(definition).to be_instance_of(Definition)
    end

    it "has correct name" do
      expect(definition.word.name).to eq 'pantaloons'
    end

    it "delegates name to root word" do
      expect(definition.name).to eq 'pantaloons'
    end

    it "has creates only one instance per word" do
      definition # ensure its created
      expect(lambda { Definition.for_word 'pantaloons' }).
             not_to change(Definition, :count)
    end

    it "fetches itself, given corresponding word" do
      definition # ensure its created
      word = Word.for_name 'pantaloons'
      expect(word.definition).to eq definition
    end

    it "can be found by a given word" do
      definition # ensure its created
      expect(Definition.by_word 'pantaloons').to eq definition
    end

    it "returns false if given word is not present" do
      expect(Definition.by_word 'xxxx').to be_false
    end

    it "returns nil if given word has no definition" do
      Word.for_name('fred')
      expect(Definition.by_word 'fred').to be_nil
    end
  end

  context "linked words)" do
    let(:definition) { DefinitionFactory.silliness }

    it "gets counts by category" do
       counts_by_category = definition.counts
       links_hash = DefinitionFactory.silliness_hash
       WordLink.each_category do |category, _|
         count = links_hash[category].size
         expect(counts_by_category[category]).to eq links_hash[category].size
       end
    end

    it "stores every linked word" do
      words = DefinitionFactory.silliness_hash.values.inject &:+
      expect(definition.words.map &:name).to eq words
    end

    DefinitionFactory.silliness_hash.each do |category_symbol, linked_words|
      context "by category: '#{category_symbol}'" do
        it "retrieves word list" do
          word_links = definition.linked(category_symbol)
          expect(word_links.map &:name).to eq linked_words
        end
      end
    end
  end

  context "xref" do
    before { DefinitionFactory.load_all }
    let(:xref_definition) { Definition.for_word 'bull' }

    it "gets counts by category" do
      xrefed_word_counts = xref_definition.xref_counts
      expect(xrefed_word_counts[:strong]).to eq 2
      expect(xrefed_word_counts[:medium]).to be_zero
    end

    it "gets words by category" do
      xrefed_words = xref_definition.xref :strong
      expect(xrefed_words.map &:name).to eq %w(babble bovine)
    end
  end

  context "json" do
    let(:definition) { DefinitionFactory.silliness }

    it "renders json fields" do
      category = WordLink::CATEGORIES.sample

      json = definition.as_json(category: category)

      expect(json['word']).to eq definition.word.as_json
      expect(json['name']).to eq 'silliness'
      expect(json['category_name']).to eq category.to_s
      expect(json['category_id']).to eq WordLink.category_index(category)
      expect(json['definition_id']).to eq definition.id
      expect(json['xref']).to be_false
      expect(json['word_count']).to eq definition.word_links_count
      expect(json['word_counts']).to eq definition.counts
      #associated_words = definition.associated_words(false, WordLink.category_index(category))
      associated_words = DefinitionFactory.silliness_hash[category]
#puts "associated_words = #{associated_words}"
      expect(json["#{category}_count"]).to eq associated_words.size
      expected_names = json[category.to_s].map {|atts| atts['name'] }
      expect(expected_names).to eq associated_words
      #expect(json[category.to_s].map &:name).to eq associated_words
    end
  end
end
