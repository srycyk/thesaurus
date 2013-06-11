require 'spec_helper'

describe "definitions/index.html.haml" do
  it "renders partials" do
    render
#puts rendered
    partials = %w(word_entry controls word_labels)
    partials.each do |partial|
      expect(rendered).to render_template(partial: '_' + partial)
    end
  end
end
