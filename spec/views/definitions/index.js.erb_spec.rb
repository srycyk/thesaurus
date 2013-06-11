require 'spec_helper'

describe "definitions/index.js.erb" do
  let :definition do
    stub_model Definition, word: stub_model(Word, name: 'and address')
  end

  let(:category) { WordLink::CATEGORIES.sample }

  before do
    view.stub selected_definition_ids: []

    assign(:definition, definition)
    assign(:category, category)
  end

  it "calls definition#counts and definition#xref_counts" do
    assign(:xref, [true, false].sample)

    definition.should_receive(:counts).with(no_args).
               any_number_of_times.and_return(Hash.new(0))

    definition.should_receive(:xref_counts).with(no_args).
               any_number_of_times.and_return(Hash.new(0))

    render
  end

  it "calls definition#linked" do
    definition.should_receive(:linked).once.with(category).and_return []
    definition.should_not_receive(:xref)

    render
  end

  it "calls definition#xref" do
    assign(:xref, true)

    definition.should_receive(:xref).once.with(category).and_return []
    definition.should_not_receive(:linked)

    render
  end

  it "renders partials" do
    render

    expect(rendered).to render_template(partial: '_word_entry')
    expect(rendered).to render_template(partial: '_linked_words')
#puts rendered
  end
end
