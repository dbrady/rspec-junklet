require 'spec_helper'

describe Junklet do
  specify { expect(Junklet).to be }

  let(:hex_regex) { /[\da-f]{32}/ }

  describe '.junklet' do
    context "with a single arg" do
      junklet :trash

      specify { expect(trash).to be }
      specify { expect(trash).to match /^trash-/ }
      specify { expect(trash).to match hex_regex }

      describe "memoization" do
        specify { expect(trash).to eq(trash) }
      end
    end

    context "with multiple args" do
      junklet :trash, :toss, :crud, :crap

      specify { expect(trash).to match /^trash-/ }
      specify { expect(trash).to match hex_regex }
      specify { expect(toss).to match /^toss-/ }
      specify { expect(toss).to match hex_regex }
      specify { expect(crud).to match /^crud-/ }
      specify { expect(crud).to match hex_regex }
      specify { expect(crap).to match /^crap-/ }
      specify { expect(crap).to match hex_regex }
    end

    context 'with separator option' do
      junklet :host_name, :last_name, :first_name, separator: '-'
      specify { expect(host_name).to match /^host-name-/ }
      specify { expect(host_name).to match hex_regex }
      specify { expect(last_name).to match /^last-name-/ }
      specify { expect(last_name).to match hex_regex }
      specify { expect(first_name).to match /^first-name-/ }
      specify { expect(first_name).to match hex_regex }
    end
  end

  describe '.junk' do
    let(:trash) { junk }

    specify { expect(trash).to match hex_regex }
    specify { expect(trash.size).to eq(32) }

    it "is not cached" do
      expect(junk).to_not eq(junk)
    end

    it "but lets on junk ARE cached" do
      expect(trash).to eq(trash)
    end

    context "with argument" do
      let(:little_trash) { junk 5 }
      let(:big_trash) { junk 100 }

      it "returns junk of that length" do
        expect(little_trash.size).to eq(5)
        expect(big_trash.size).to eq(100)
      end

      it "returns hex chars of that length" do
        expect(little_trash).to match /^[\da-f]{5}$/
        expect(big_trash).to match /^[\da-f]{100}$/
      end
    end

    context "with type: :decimal" do
      let(:junk_integer) { junk 15, type: :integer }
      it "returns the request number of decimal digits" do
        expect { (widget_id).to be_a Integer }
        expect { (widget_id.to_s.size).to eq(15) }
      end
    end
  end
end
