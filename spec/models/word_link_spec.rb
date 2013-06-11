
require 'spec_helper'

describe WordLink do
  context "mapping for attribute 'category'" do
    mappings = { generic: 0, opposite: 1, strong: 2, medium: 3, weak: 4 }

    mappings.each do |name, index|
      it "converts name, '#{name}' to integer, #{index}" do
        expect(WordLink.category_index name).to eq index
      end
      it "converts integer, #{index} to name, '#{name}'" do
        expect(WordLink.category_word index).to eq name
      end
    end

    it "iterates through categories in display order" do
      categories = []
      WordLink.each_category {|name, index| categories << [name, index] }

      expected_categories = [ [:strong, 2], [:medium, 3], [:weak, 4],
                              [:generic, 0], [:opposite, 1] ]

      expect(categories).to eq expected_categories
    end
  end

  context "adding links" do
    let(:definition) { Definition.for_word 'babble' }

    let(:word_links) { definition.word_links.add(0, 'drivel', 'nonsense') }

    it('returns array') { expect(word_links).to be_instance_of(Array) }

    it('returns correct number of items') { expect(word_links.size).to eq 2 }

    it 'returns correct instance' do
      expect(word_links.first).to be_instance_of(WordLink)
    end

    it('returns a saved instance') { expect(word_links.first).to be_persisted }
  end

  context "linking words" do
    let(:definition) { Definition.for_word 'babble' }

    let(:word_link) { definition.word_links.add(2, 'bull').first }

    it('sets root word') { expect(word_link.definition.name).to eq 'babble' }

    it('sets linked word') { expect(word_link.word.name).to eq 'bull' }

    it('sets category') { expect(word_link.category).to eq 2 }

    it('gets category name') { expect(word_link.category_word).to eq :strong }
  end

  context "linked words" do
    let(:definition) { DefinitionFactory.silliness }
    let(:counts_by_category) { definition.word_links.counts }

    DefinitionFactory.silliness_hash.each do |category_name, word_names|
      context "for category '#{category_name}'" do
        it 'finds linked records by category index' do
          category_index = WordLink.category_index category_name

          word_links = definition.word_links.
                       with_category(category_index).sorted.all

          expect(word_links.map &:name).to eq word_names
        end

        it 'finds linked records by category name' do
          word_links = definition.word_links.
                       with_category_name(category_name).sorted.all

          expect(word_links.map &:name).to eq word_names
        end

        it "counts the number of linked records" do
          expected_word_count = counts_by_category[category_name]
          expected_word_count.should eq word_names.size
        end
      end
    end
  end
end
