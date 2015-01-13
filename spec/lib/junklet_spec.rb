require 'spec_helper'

describe Junklet do
  specify { expect(Junklet).to be }

  let(:uuid_regex) { /-[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/ }

  describe '.junklet' do
    context "with a single arg" do
      junklet :junk
      
      specify { expect(junk).to be }
      specify { expect(junk).to match /^junk-/ }
      specify { expect(junk).to match uuid_regex }
      
      describe "memoization" do
        specify { expect(junk).to eq(junk) }
      end
    end

    context "with multiple args" do
      junklet :junk, :toss, :crud, :crap

      specify { expect(junk).to match /^junk-/ }
      specify { expect(junk).to match uuid_regex }
      specify { expect(toss).to match /^toss-/ }
      specify { expect(toss).to match uuid_regex }
      specify { expect(crud).to match /^crud-/ }
      specify { expect(crud).to match uuid_regex }
      specify { expect(crap).to match /^crap-/ }
      specify { expect(crap).to match uuid_regex }
    end

    context 'with separator option' do
      junklet :host_name, :last_name, :first_name, separator: '-'
      specify { expect(host_name).to match /^host-name-/ }
      specify { expect(host_name).to match uuid_regex }
      specify { expect(last_name).to match /^last-name-/ }
      specify { expect(last_name).to match uuid_regex }
      specify { expect(first_name).to match /^first-name-/ }
      specify { expect(first_name).to match uuid_regex }
    end
  end
end
