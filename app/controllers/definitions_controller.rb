
class DefinitionsController < ApplicationController
  MAX_SELECTED = 20

  before_filter :require_definition, only: %w(show xref phrases)

  except = %w(index phrases clear_selected sort_selected remove_selected)

  before_filter :require_category, except: except

  helper_method :selected_definition_ids

  def index
  end

  def find
    word = params[:word]

    if word.blank?
      @error_message = "NO word given"
    elsif @definition = Definition.by_word(word, is_json?)
      add_selected_definition @definition
    elsif @definition.nil?
      @error_message = "NO linked words for #{word}"
    else
      @error_message = "Word NOT found #{word}"
    end
    template_renderer
  end

  def show
    add_selected_definition @definition
    template_renderer
  end

  def xref
    @xref = true
    template_renderer
  end

  def random
    @definition = Definition.random
    template_renderer
  end

  def phrases
#raise @definition.inspect
    template_renderer template: :phrases
  end

  def clear_selected
    session[:definition_ids] = []

    selected_renderer
  end

  def sort_selected
    selected_definition_ids.sort_by! do |id|
      Definition.find(id).name.downcase
    end

    selected_renderer
  end

  def remove_selected
    selected_definition_ids.delete params[:id]

    selected_renderer
  end

  private

  def require_definition
    @definition = Definition.find params[:id]
  end

  def require_category
    @category = (params[:category] || :strong).to_sym
  end

  def selected_definition_ids
    session[:definition_ids] ||= []
  end

  def add_selected_definition(definition)
    return if is_json?

    definition_ids = selected_definition_ids

    unless definition_ids.include? definition.to_param
      definition_ids.unshift definition.to_param
    end

    definition_ids.pop while definition_ids.size > MAX_SELECTED
  end

  def selected_renderer
    render '_selected', layout: false
  end

  def template_renderer(options={})
    if is_json?
      options.merge! json: definition_json || @error_message
    else
      xref!
    end
    super
  end

  def definition_json
    return unless @definition

    @definition.as_json category: params[:category], xref: xref?
  end

  def is_json?
    request.format.json?
  end

  def xref!
    @xref ||= xrefed_params?
  end

  def xref?
    @xref or xrefed_params?
  end

  def xrefed_params?
    params.has_key?(:xref) and
        not %w(0 f false).include?(params[:xref].to_s.downcase)
  end
end
