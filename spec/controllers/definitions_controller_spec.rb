require 'spec_helper'

describe DefinitionsController do
  let (:silliness) { DefinitionFactory.silliness }

  let (:category) { WordLink::CATEGORIES.sample }

  let(:invalid_id) { Definition.max(:id) + 10_000 }

  shared_examples_for 'a response' do
    it "renders index successfully" do
      expect(response).to be_success
      expect(response).to render_template :index
    end
  end

  shared_examples_for 'a definition' do
    it "returns definition" do
      expect(assigns :definition).to eq silliness
    end
  end

  shared_examples_for 'a category' do
    it "returns category" do
      expect(assigns :category).to eq category
    end
  end

  shared_examples_for 'a default category' do |action|
    context "default category" do
      it "assigns 'strong' to category" do
        get action, id: silliness.to_param
        expect(assigns :category).to eq :strong
      end
    end
  end

  shared_examples_for 'an invalid id' do |action|
    it "raises error with invalid id" do
      expect(lambda { get action, id: invalid_id }).to raise_error
    end
  end

  shared_examples_for 'an xref' do |xref_value|
    it "#{xref_value ? 'sets' : 'does not set'} 'xref' flag" do
      expect(assigns :xref).to eq xref_value
    end
  end

=begin
  shared_examples_for 'a word keeper' do |action|
    let :definition_ids do
      session = {}
      DefinitionFactory.load_all.map do |definition|
        get action, {id: definition.to_param}, session
        definition.to_param
      end
    end

    it "stores definition ids in session" do
      definition_ids # prefetch
puts
puts "#{definition_ids.inspect}"
puts "#{session.inspect}"
      expect(session[:definition_ids]).to eq definition_ids
    end
  end
=end

  context "GET 'index'" do
    before { get 'index' }

    it_behaves_like 'a response'
  end

  context "GET 'find'" do
    context "valid input" do
      before { get 'find', word: silliness.name, category: category }

      it_behaves_like 'a response'

      it_behaves_like 'a definition'

      it_behaves_like 'a category'

      it_behaves_like 'an xref', false
    end

    context 'storing definition id in session' do
      it "stores definition id in session" do
        session[:definition_ids] = []
        get 'find', word: silliness.name
        expect(session[:definition_ids]).to eq [ silliness.to_param ]
      end
    end

    context "invalid input" do
      it "returns error message if unknown word" do
        get 'find', word: 'fyufygkhg'
        expect(assigns :error_message).to be_present
        expect(assigns :definition).to eq false
      end

      it "returns error message if known word" do
        get 'find', word: Word.for_name('bug').name
        expect(assigns :error_message).to be_present
        expect(assigns :definition).to be_nil
      end
    end

    context 'default category' do
      it "assigns 'strong' to category" do
        get 'find', word: silliness.name
        expect(assigns :category).to eq :strong
      end
    end

    context "json" do
      before { request.env["HTTP_ACCEPT"] = "application/json" }

      #before { DefinitionFactory.load_all }

      it "renders correctly" do
        get 'find', word: silliness.name, category: category #, format: :json
        json = JSON.parse(response.body)
        expect(json).to eq silliness.as_json(category: category)
      end

      it "handles unknown word" do
        get 'find', word: 'fyfgjg', category: category
        json = JSON.parse(response.body)
        expect(response.code).to eq '404'
        expect(json['error']).to be_present
      end
    end
  end

  context "GET 'show'" do
    context "valid input" do
      before { get 'show', id: silliness.to_param, category: category }

      it_behaves_like 'a response'

      it_behaves_like 'a definition'

      it_behaves_like 'a category'

      it_behaves_like 'an xref', false

      #it_behaves_like  'a word keeper', 'show'
    end

    context "invalid input" do
      it_behaves_like 'an invalid id', 'show'
    end

    it_behaves_like 'a default category', 'show'
  end

  context "GET 'xref'" do
    context "valid input" do
      before { get 'xref', id: silliness.to_param, category: category }

      it_behaves_like 'a response'

      it_behaves_like 'a definition'

      it_behaves_like 'a category'

      it_behaves_like 'an xref', true
    end

    context "invalid input" do
      it_behaves_like 'an invalid id', 'xref'
    end

    it_behaves_like 'a default category', 'xref'
  end
end
