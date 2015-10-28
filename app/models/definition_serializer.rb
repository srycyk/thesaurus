
class DefinitionSerializer
  attr_accessor :definition, :opts

  def initialize(definition, opts={})
    self.definition = definition

    set_opts opts
  end

  def set_opts(opts={})
    opts.stringify_keys!

    self.opts = opts 
  end

  def as_json(opts={})
    set_opts opts

    fields
    #.merge! opts
  end

  def fields
    associated = phrases? ? [] : associated_words

    { "name" => definition.word.name,
      "word" => definition.word.as_json,
      "category_name" => category_name,
      "category_id" => category_index,
      "weight" => (definition.weight * 100).round(3),
      "labels" => definition.word.labels,
      "label" => definition.word.abb_labels_to_s,
      "definition_id" => definition.id,
      "word_count" => definition.word_links_count,
      "word_counts" => definition.counts,
      "xref_word_count" => definition.xref_count_total,
      "xref_word_counts" => definition.xref_counts,
      "_xref" => xref?,
      "_phrases" => phrases?,
      "_labels" => labels?,
      "_ordered_by_usage" => ordered_by_usage?,
      "_associated_labels" => associated_labels,
      "phrase_count" =>  phrase_count,
      "phrases" => phrases,
      "#{category_key}_count" => associated.size,
      "#{category_key}" => associated
    }
  end

  def category_word_to_index(category)
    category = :strong unless category

    if category.to_s =~ /^\d+$/
      category.to_i
    else
      WordLink.category_index(category)
    end
  end

  def associated_words_query(xref, category, by_usage, labels=nil)
    relation = if xref
                 definition.word.words
               else
                 definition.words
               end

    relation = relation.with_category(category)

    relation = relation.sort_by_usage if by_usage

    relation = relation.with_labels labels if labels

    relation.map &:as_json
  end

  def associated_words
    associated_words_query xref?, category_index,
                           ordered_by_usage?, associated_labels
  end

  def phrase_relation
    definition.word.phrases
  end

  def phrase_count
    phrase_relation.count
  end

  def phrases
    if phrases?
      phrase_relation.to_a
    else
      []
    end
  end

  def xref?
    opts['xref'] ? true : false
  end

  def category_key
    (xref? ? 'xref_' : '') + category_name
  end

  def category_name
    WordLink.category_to_s category_index
  end

  def category_index
    category_word_to_index opts['category']
  end

  def ordered_by_usage?
    opts['by_usage'] ? true : false
  end

  def associated_labels
    Word.labels_to_names opts['labels']
  end

  def phrases?
    opts['phrases'] ? true : false
  end

  def labels?
    opts['labels'].blank? ? false : true
  end
end
