require 'spec_helper'

describe Junklet do
  specify { expect(Junklet).to be }

  let(:regex) { /-[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/ }

  describe '.junklet' do
    context "with a single arg" do
      junklet :junk
      
      specify { expect(junk).to be }
      specify { expect(junk).to match /^junk-/ }
      specify { expect(junk).to match regex }
      
      describe "memoization" do
        specify { expect(junk).to eq(junk) }
      end
    end

    context "with multiple args" do
      junklet :junk, :toss, :crud, :crap

      specify { expect(junk).to match /^junk-/ }
      specify { expect(junk).to match regex }
      specify { expect(toss).to match /^toss-/ }
      specify { expect(toss).to match regex }
      specify { expect(crud).to match /^crud-/ }
      specify { expect(crud).to match regex }
      specify { expect(crap).to match /^crap-/ }
      specify { expect(crap).to match regex }
    end
  end
end
