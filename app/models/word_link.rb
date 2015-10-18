
# WordLink(id: integer, category: integer, definition_id: integer, word_id: integer)
class WordLink < ActiveRecord::Base
  CATEGORIES = [ :generic, :opposite, :strong, :medium, :weak ]

  DISPLAY_CATEGORIES = [ :strong, :medium, :weak, :generic, :opposite ]

  belongs_to :definition, counter_cache: true

  belongs_to :word

  scope :with_category, -> category { where category: category.to_i }

  scope :with_category_name, -> name { with_category category_index(name) }

  scope :with_definition, -> definition { where definition_id: definition.to_param }

  scope :with_word, -> word { where word_id: word.to_param }
  #scope :with_words, -> words { where word_id: words.map(&:to_param) }
  
  scope :sorted, -> { joins(:word).order('words.name') }

  scope :select_word_counts, -> { select('category, count(word_id) as word_count') }

  scope :select_definition_counts, -> { select('category, count(definition_id) as definition_count') }

  #scope :include_words, -> { includes(:word, definition: :word) }

=begin
  CATEGORIES.each_with_index do |category, index|
    scope category, sorted.with_category(index)
    #scope category, lambda { sorted.with_category index }
  end
=end

  delegate :name, to: :word

  class << self
    def add(category, *words)
      category = category_index category if Symbol === category

      words.flatten.collect do |word|
        word = Word.for_name word if String === word

        with_category(category).create word: word
      end
    end

    def counts
      counts = HashWithIndifferentAccess.new 0
      select_word_counts.group(:category).each do |word_link|
        counts[word_link.category_word] = word_link[:word_count]
      end
      counts
    end

    #def counts_for(category_name)
    #  with_category_name(category_name).count
    #end

    def category_index(category_name)
      CATEGORIES.index category_name.to_sym
    end
    def category_word(category_index)
      CATEGORIES[category_index.to_i]
    end

    def categories_equal?(category1, category2)
      category_to_s(category1) == category_to_s(category2)
    end

    def category_to_s(category)
      if Fixnum === category or category.to_s =~ /^\d+$/
        category_word(category).to_s
      else
        category.to_s
      end
    end

    def each_category
      DISPLAY_CATEGORIES.each do |name|
        yield name, category_index(name)
      end
    end
  end

  def category_word
    self.class.category_word category
  end

  def to_s(verbose=false)
    (verbose ? "#{definition.name}: " : '') +
        "#{name}(#{category_word})"
  end
end
