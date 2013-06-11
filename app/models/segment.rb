
# Segment(id: integer, phrase_id: integer, word_id: integer)
class Segment < ActiveRecord::Base
  belongs_to :phrase, counter_cache: true,
                      class_name: 'Word', foreign_key: :phrase_id

  belongs_to :word

  class << self
    STOP_FILE = 'stop'

    def load_phrases
      File.unlink STOP_FILE if File.file? STOP_FILE

      max_count = (ENV['MAX'] || 500).to_i

      count = 0

      Word.find_in_batches(batch_size: 100) do |words|
        count += 1

        transaction { words.each {|word| create_phrase word } }

        puts "#{count}. #{words.last}" #if count % 500 == 0

        break if File.file? STOP_FILE #or count > max_count
      end
    end
 
    def create_phrase(word)
      word_parts = word.name.split(/[\s-]/)
      if word_parts.size > 1
        transaction do
          word_parts.each do |word_part|
            if segment_word = Word.with_name(word_part).first
              create phrase: word, word: segment_word
            end
          end
        end
      end
    end
  end
end
