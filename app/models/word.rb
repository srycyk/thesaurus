
# Word(id: integer, name: string, proper_name: boolean, noun: boolean, verb: boolean, adverb: boolean, adjective: boolean, typed: boolean, segments_count: integer)
class Word < ActiveRecord::Base
  WORD_LABELS = { 'noun' => 'n', 'verb' => 'v',
                  'adjective' => 'adj', 'adverb' => 'adv',
                  'proper_name' => 'proper name', 'name' => 'name' }

  has_one :definition

  has_many :word_links

  has_many :definitions, through: :word_links

  has_many :words, through: :definitions

  has_many :segments, dependent: :destroy

  has_many :segment_phrases, foreign_key: :phrase_id, class_name: :'Segment'

  has_many :word_parts, through: :segment_phrases, source: :word

  has_many :phrases, through: :segments, order: 'words.name' #, includes: :definitions

  scope :with_name, -> name { where name: name.downcase }

  scope :with_category, -> category { where word_links: {category: category} }

  scope :with_labels, -> labels { where labels_to_where labels }

  scope :sort_by_usage, -> { joins(:definition).order 'definitions.word_links_count DESC' }

=begin
  scope :in_common, lambda {|d1, d2|
        joins(:word_links)
        .where(word_links: {definition_id: [ d1.to_param, d2.to_param ]})
  }
=end

  validates :name, presence: true

  def self.for_name(name)
    with_name(name.downcase).first_or_create do |word|
      word.proper_name = name =~ /^[A-Z]/ ? true : false
    end
  end


  def to_s
    name
  end

  #def typed?
  #  proper_name? or noun? or verb? or adjective? or adverb?
  #end

  def abb_labels
    @abb_labels ||= labels.collect {|type| WORD_LABELS[type] }
  end

  def abb_labels_to_s
    abb_labels.empty? ?  '' : "(#{abb_labels * ' '})"
  end

  def labels_to_s(unknown=nil, sep=' ')
    labels_as_s = labels * sep
    labels_as_s << sep << unknown if labels_as_s.blank? and unknown
    labels_as_s
  end

  def labels
    @labels ||= begin
                  labels = []
                  labels << 'noun' if noun?
                  labels << 'verb' if verb?
                  labels << 'adjective' if adjective?
                  labels << 'adverb' if adverb?
                  labels << 'name' if proper_name?
                  labels
                end
  end

  class << self
    ALL_LABELS = %w(name noun verb adjective adverb)

    def labels_to_where(labels)
      labels = labels_to_names labels

      sql = ''

      labels.each do |label|
        sql << ' OR ' unless sql.blank?

        sql << table_name << '.' << label << ' = ?'
      end

      return sql, *([true] * labels.size)
    end

    def labels_to_names(labels)
      labels = labels.split(/,\s*/) if String === labels

      (labels || []).map {|label| get_label label }
            .select {|label| ALL_LABELS.include? label }
    end

    private

    def get_label(label)
      label = label.to_s

      if WORD_LABELS.has_key? label
        label
      elsif WORD_LABELS.has_value? label
        WORD_LABELS.key label
      end
    end
  end

  class << self
    STOP_FILE = 'stop'

    # Batch job for classifying words from WordNet
    # Seems to slow down if run for too long
    def load_word_labels(word_net_path=nil, show_progress=true)
      require 'words'

      File.unlink STOP_FILE if File.file? STOP_FILE

      word_net_path = '/usr/share/WordNet/' unless word_net_path

      word_net = Words::Wordnet.new :pure, word_net_path

      max = (ENV['MAX'] || 50).to_i

      total, done = Word.count, Word.where(typed: true).count
      puts " #{total}: #{pc done, total} done(#{done}), #{pc total-done, total} to do(#{total-done}) - max = #{max}"
      count, batch = -1, 0
      where(typed: false).find_in_batches(batch_size: 200) do |words|
        #word_net.close! if word_net.connected?; word_net.open!
        batch += 1
        transaction do
          words.each do |word|
            if sense = word_net.find(word.name)
              word.update_attributes noun: sense.nouns?,
                                     verb: sense.verbs?,
                                     adjective: sense.adjectives?,
                                     adverb: sense.adverbs?,
                                     typed: true

            else
              word.update_attribute :typed, true
            end

            if show_progress and (count+=1) % 1000 == 0
              puts "#{count}(#{pc count, total}, #{batch}). " +
                   "#{word} (#{word.labels * ', '})"
            end
          end
        end
        break if File.file? STOP_FILE or batch > max
      end
    end

    def pc(top, bottom)
      "#{'%.2f' % (top * 100.0 / bottom)}%"
    end
  end
end
