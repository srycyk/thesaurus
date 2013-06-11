
module DefinitionFactory
  extend self
  def silliness_hash
    { generic: %w(foolishness),
      opposite: %w(gravity sobriety),
      strong: %w(fatuity frivolity nonsense),
      medium: %w(fatuousness giddiness taradiddle),
      weak: %w(absurdity folly twiddle-twaddle unwiseness) }
  end
  def silliness_array
    [ 'silliness', silliness_hash ]
  end
  def silliness
    save *silliness_array
  end
 
  def babble_hash
    { generic: %w(foolishness),
      opposite: %w(meaningful),
      strong: %w(bull bollocks nonsense),
      medium: %w(drivel taradiddle),
      weak: %w(absurdity) }
  end
  def babble_array
    [ 'babble', babble_hash ]
  end
  def babble
    save *babble_array
  end

  def bovine_hash
    { strong: %w(bull bollocks) }
  end
  def bovine_array
    [ 'bovine', bovine_hash ]
  end
  def bovine
    save *bovine_array
  end

  def joke_hash
    { generic: %w(foolishness),
      opposite: %w(sobriety),
      strong: %w(bollocks) }
  end
  def joke_array
    [ 'joke', joke_hash ]
  end
  def joke
    save *joke_array
  end

  def save(root_word, linked_words)
    #definition = nil
    Definition.transaction do
      definition = Definition.for_word root_word
      linked_words.each do |category, words|
        #definition = definition.add_linked category, words
        category_index = WordLink.category_index category
        words.each do |word|
          word = Word.for_name word
          next if definition.word_links.with_category(category_index).with_word(word).exists?
          definition.word_links.create category: category_index, word: word
        end
      end
    end
    #definition.word_links(true)
    #definition
    Definition.for_word root_word
  end

  def load_all
    [ silliness, babble, bovine, joke ]
  end

  def get_all
    [ silliness_array, babble_array, bovine_array, joke_array ]
  end
end

if __FILE__ == $0
  DefinitionFactory.get_all.each {|n, h| puts "#{n}: #{h.inspect}", '' }
end
