require 'spec_helper'

describe DefinitionsHelper do
  context "displays percentages" do
    it "rounds up" do
      expect(helper.pc 0.3333333333, 1). to eq '33.3%'
    end
  end
end
