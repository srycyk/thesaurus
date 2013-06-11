require 'spec_helper'

describe Word do
  let (:name) { 'folly' }

  context "saves instances given a word as a string" do
    subject { Word.for_name name }

    it { expect(subject).to be_instance_of(Word) }

    it { expect(subject.persisted?).to be_true }

    it { expect(subject.to_s).to eq name }
  end

  context "looking up by name" do
    it "finds record given a name" do
      word = Word.for_name name
      found_word = Word.where name: name
      expect(found_word.first).to eq word
    end

    it "rejects words with no name" do
      word = Word.for_name ''
      expect(word).to have(1).error_on(:name)
    end
  end

  context "word labels" do
    let(:word) { Word.for_name name }

    it "shows word labels" do
      label_atts = {}
      Word::WORD_LABELS.keys.reject{|k| k == 'name' }.each do |word_label|
        label_atts[word_label] = [ true, false ].sample
      end
      word.update_attributes label_atts

      labels = label_atts.reject{|_, v| not v }.keys
      #if labels.include? 'name'
      #  labels.delete 'name'
      #end
      if labels.include? 'proper_name'
        labels[labels.index('proper_name')] = 'name'
      end
      expect(word.labels).to eq labels
    end
  end

  context "compound words" do
    let(:phrase) { 'word1 word2 word3-word4' }

    let(:phrase_word) { Word.for_name phrase }

    let(:word_names) { phrase.split(/[\s-]/) }

    before do
      word_names.each {|word_name| Word.for_name(word_name) }

      Segment.create_phrase phrase_word
    end

    it "splits up a phrase into single words" do
      expect(phrase_word.word_parts.collect &:name).to eq word_names
      #expect(phrase_word.segments_count).to eq word_names.size
    end

    it "retrieves a phrase given a single word" do
      segment = Word.with_name('word4').first
#puts "segment.phrases = #{segment.phrases(true).inspect}"
      expect(segment.phrases.first).to eq phrase_word
    end
  end
end
