
module DefinitionsHelper
  def pc(float, precision=3)
    "%.#{precision}f%%" % (float * 100)
  end

  def current?(selected_xref, current_xref,
               selected_category, current_category)
    current_xref == selected_xref and
        WordLink.categories_equal?(selected_category, current_category)
  end

  def each_category
    WordLink.each_category {|name, index| yield name, index }
  end

  def total_count(xref, definition)
    xref ? definition.xref_count_total : definition.word_links_count
  end

  def total_count_text(xref, definition_or_count)
    total_count = if Definition === definition_or_count
                    total_count xref, definition_or_count
                  else
                    definition_or_count.to_i
                  end

    links_text = xref ? "xref link" : "link"
    pluralize total_count, links_text
  end

  def count_by_category(xref, definition, category)
    if xref
      definition.xref_counts[category.to_sym]
    else
      definition.counts[category.to_sym]
    end
  end

  def count_by_category_text(xref, definition_or_count, category)
    count = if Definition === definition_or_count
              count_by_category xref, definition_or_count, category
            else
              definition_or_count.to_i
            end

    "#{count} #{category}#{xref ? ' (xref)' : ''}"
  end

  def path_to_linked_words(xref, definition, category=nil)
    if xref
      definitions_xref_path(id: definition, category: category)
    else
      definitions_show_path(id: definition, category: category)
    end
  end

  def associated_words(xref, definition, category)
    link_method = xref ? :xref : :linked
    definition.send(link_method, category.to_sym)
  end

  def button_class(xref)
    "btn-#{xref ? 'info' : 'primary'} category-button"
  end

  def linked_words_id(xref, definition, category=nil)
    "#{dom_id definition}_#{category}#{xref ? '_xref' : ''}"
  end

  def all_word_labels
    %w(name noun verb adjective adverb unknown all)
  end

  def word_label_plural(word_label)
    word_label + (%w(unknown all).include?(word_label) ? '' : 's')
  end

  def selected_definitions
    @selected_definitions ||= begin
      selected_definition_ids.map do |id|
        Definition.include_word.with_id(id).first
      end
    end
  end
end
