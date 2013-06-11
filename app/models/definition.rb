
# Definition(id: integer, word_id: integer, word_links_count: integer)
class Definition < ActiveRecord::Base
  belongs_to :word

  has_many :word_links, dependent: :destroy

  has_many :words, through: :word_links

  scope :with_word, lambda {|word| where word_id: word.to_param }

  scope :with_id, lambda {|id| where id: id }

  scope :include_word, includes(:word)

  scope :include_words, includes(:word, word_links: :word)

  delegate :name, :phrases, to: :word

  class << self
    def for_word(word)
      word = Word.for_name(word) if String === word

      with_word(word).first_or_create
    end

    def by_word(word, exclude_words=true)
      word = Word.with_name(word).first if String === word
      if not word
        false
      else
        if exclude_words
          with_word(word).first
        else
          include_words.with_word(word).first
        end
      end
    end
  end

  def add_linked(category, *linked_words)
    word_links.add category, linked_words.flatten
    self
  end

  class << self
    def xupdate_word_links_count(show_progress=true)
      count = 0
      find_each do |definition|
        next if definition.word_links_count > 0

        count = definition.word_links.count
        definition.update_attribute :word_links_count, count

        if show_progress and (count += 1) % 1000 == 0
          puts "#{count}. #{definition.word} (#{definition.word_links_count})"
        end
      end
    end

    #TODO put into table, counters
    # cache Definition.count
    def get_count(reload=false)
      @total_count = nil if reload

      @total_count ||= begin
        subdir = Rails.env.test? ? 'spec' : 'tmp'
        path = File.join Rails.root, subdir, '_definitions_count.txt'
        if File.file? path
          IO.read(path).to_i
        else
          total_count = count
          File.open(path, 'w') {|stream| stream.puts total_count }
          total_count
        end
      end
    end
  end

    #TODO put into table, counters
  def self.max_word_links
    @max_word_links ||= maximum(:word_links_count) || 1
  end

  def self.random
    find(rand(get_count) + 1)
  end

  def weight
    @weight ||= word_links_count.to_f / self.class.max_word_links
  end

  def linked(category)
    if Symbol === category
      category = WordLink.category_index category
    end

    words.with_category(category).includes(:definition)
  end

  def counts
    @counts ||= word_links.counts
  end

  def xref(category)
    if Symbol === category
      category = WordLink.category_index category
    end

    word.words.with_category(category).includes(:definition)
  end

  def xref_counts
    @xref_counts ||= begin
      xref_counts = HashWithIndifferentAccess.new 0

      word.word_links.select_definition_counts
                     .group(:category).each do |word_link|
        xref_counts[word_link.category_word] = word_link[:definition_count]
      end

      xref_counts
    end
  end

  def xref_count_total
    xref_counts.values.inject &:+
  end

=begin
  def xrefs
    @xref ||= begin
      WordLink.includes(definition: :word)
              .where(word_links: {word_id: word_id})
              .group_by {|word_link| word_link.category_word }
              .each do |category, word_links|
                word_links.map! {|word_link| word_link.definition.word }
              end
    end
  end

  def xref_counts_by_category
    @xref_counts_by_category ||= xrefs.inject({}) do |xref_counts, pair|
                                   xref_counts[pair.first] = pair.last.size
                                   xref_counts
                                 end
  end
=end

  #TODO return phrases as well
  def as_json(opts={})
    opts.stringify_keys!

    xref = opts.delete('xref') || false

    category = opts.delete('category') || :strong
    category = if category.to_s =~ /^\d+$/
                 category.to_i
               else
                 WordLink.category_index(category)
               end

    associated_words = associated_words xref, category

    { "word" => word.name,
      "category_name" => WordLink.category_to_s(category),
      "category_id" => category,
      "weight" => (weight * 100).round(3),
      "labels" => word.labels,
      "definition_id" => id,
      "word_count" => word_links_count,
      "word_counts" => counts,
      "xref_word_count" => xref_count_total,
      "xref_word_counts" => xref_counts,
      "xref" => xref,
      "associated_count" => associated_words.size,
      "associated" => associated_words }.merge! opts
  end

  def to_s
    "#{word}: #{word_links.map(&:to_s) * ', '}"
  end

  def associated_words(xref, category)
    if xref
      word.words.with_category(category)
    else
      words.with_category(category)
    end.map &:name
  end

  # Batch job for loading db from gzipped csv file
  class << self
    def from_array(values)
      root_word, category, *linked_words = values

      definition = for_word root_word

      linked_words.delete_if {|word| word.downcase == root_word.downcase }

      definition.add_linked category, linked_words
    end

    def load_db(path=nil, show_progress=true)
      require 'zlib'

      path = File.join 'db', 'thes.csv.gz' unless path

      count = -1
      Zlib::GzipReader.open(path) do |gz_stream|
        gz_stream.each_line do |line|
          transaction do
            if show_progress and (count += 1) % 1000 == 0
              puts "#{count}. #{line}"
            end
            from_array line.chomp.split(',')
          end
        end
      end
    end
  end
end
