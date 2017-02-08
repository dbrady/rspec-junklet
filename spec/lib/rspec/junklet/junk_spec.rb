require 'spec_helper'
require PROJECT_ROOT + 'lib/rspec/junklet/junk.rb'

RSpec.configure do |config|
  config.extend(RSpec::Junklet::Junk)    # This lets us say junk() in describes and contexts
  config.include(RSpec::Junklet::Junk)    # This lets us say junk() in describes and contexts
end

describe ::RSpec::Junklet::Junk do
  let(:hex_regex) { /^[0-9a-f]+$/ }

  describe "#junk" do
    it "is a hexadecimal string" do
      expect(junk).to match hex_regex
    end

    it "defaults to 32 characters" do
      expect(junk.size).to eq(32)
    end

    it "is random each time" do
      expect(junk).to_not eq(junk)
    end
  end

  describe "#junk(size)" do
    it "emits exactly (size) characters" do
      expect(junk(14).size).to eq 14
    end
  end

  describe "#junk(:int)" do
    it "generates a Fixnum" do
      expect(junk(:int)).to be_a Integer
    end

    context "with min or max option" do
      let(:val) { junk :int, min: 3, max: 5 }

      it "constrains the value" do
        expect(val).to be >= 3
        expect(val).to be <= 5
      end
    end

    context "with size option" do
      let(:val) { junk :int, size: 4 }

      it "generates a number with that many digits (no leading zeroes)" do
        expect(val).to be >= 1000
        expect(val).to be <= 9999
      end
    end
  end

  describe "junk(:bool)" do
    let(:val) { junk :bool }

    it "returns a boolean" do
      expect([false, true]).to include val
    end
  end

  describe "junk(<Array>)" do
    let(:options) { [:a, :b, 3] }
    let(:val) { junk options }

    it "returns an element of the collection" do
      expect(options).to include val
    end
  end

  describe "junk(<Enumerable>)" do
    let(:options) { (1..5) }
    let(:val) { junk options }

    it "returns an element of the collection" do
      expect(options).to include val
    end

    it "calls #.to_a on the Enumerable" do
      # This expectation is included to document that this happens, and could
      # potentially cause a memory problem. Don't do junk (1..1_000_000_000_000)
      # unless you're all done with having memory.
      expect(options).to receive(:to_a).and_call_original
      expect(options).to include val
    end
  end

  describe "junk(<Proc>)" do
    let(:lambda) { ->{ [1,2,3].sample } }
    let(:val) { junk lambda }

    it "evaluates the proc" do
      expect(lambda).to receive(:call).and_call_original
      expect([1,2,3]).to include val
    end
  end

  describe "exclude option" do
    let(:even_numbers) { [0,2,4,6,8,10] }
    let(:odd_numbers) { [1,3,5,7,9] }

    context "when excluding an item" do
      let(:val) { junk :bool, exclude: true }

      it "excludes the item" do
        expect(val).to be false
      end
    end

    context "when excluding a list" do
      let(:val) { junk :int, max: 10, exclude: odd_numbers }

      it "excludes all of the items" do
        expect(val).to be_in even_numbers
      end
    end

    context "when excluding an enumerator" do
      let(:odd_enum) { 1.step(9, 2) }
      let(:val) { junk :int, max: 10, exclude: odd_enum }

      it "excludes the elements of the enumerable" do
        expect(val).to be_in even_numbers
      end

      it "does not call #.to_a on the enumerable to get the complete list" do
        expect(odd_enum).to_not receive(:to_a)
        expect(val).to be_in even_numbers
      end

      it "calls #include? on the enumerable to determine rejection" do
        expect(odd_enum).to receive(:include?).at_least :once
        expect(val).to be_in even_numbers
      end
    end

    context "when excluding a Proc" do
      let(:odd_proc) { ->(x) { [1,3,5,7,9].include? x } }
      let(:val) { junk :int, max: 10, exclude: odd_proc }

      it "passes the junk candidates to the proc" do
        # expect(odd_proc).to_receive(:call)
      end

      it "excludes the candidate if the proc returns true" do
        expect(val).to be_in even_numbers
      end
    end
  end



  #   context "when excluding a Proc" do
  #     let(:junk) { subject.junk :int, max: 10, exclude: ->(x) { x%2==1 } }
  #     specify { expect([0,2,4,6,8,10]).to include(junk) }
  #   end
  # end

  # context "with format option" do
  #   context "when format is :string" do
  #     let(:junk) { subject.junk :int, max: 0, format: :string }

  #     specify { expect(junk).to eq("0") }
  #   end

  #   context "when format is :int" do
  #     let(:junk) { subject.junk ["42"], format: :int }

  #     specify { expect(junk).to be_kind_of(Integer) }
  #     specify { expect(junk).to eq(42) }
  #   end

  #   context "when format is a format string" do
  #     let(:junk) { subject.junk [15], format: "0x%02x" }

  #     it "formats the value by the string" do
  #       expect(junk).to eq("0x0f")
  #     end
  #   end

  #   context "when format is a Junklet::Formatter" do
  #     class HexTripler < RSpec::Junklet::Formatter
  #       def value
  #         input * 3
  #       end

  #       def format
  #         "0x%02x" % value
  #       end
  #     end

  #     let(:junk) { subject.junk [4], format: HexTripler }

  #     it "delegates to #format" do
  #       expect(junk).to be_kind_of(String)
  #       expect(junk).to eq("0x0c")
  #     end
  #   end

  #   context "when format is a class that quacks like Junklet::Formatter" do
  #     class HexDoubler
  #       def initialize(input)
  #         @n = input
  #       end

  #       def value
  #         @n * 2
  #       end

  #       def format
  #         "0x%04x" % value
  #       end
  #     end

  #     let(:junk) { subject.junk [12], format: HexDoubler }

  #     it "works as expected" do
  #       expect(junk).to be_kind_of(String)
  #       expect(junk).to eq("0x0018")
  #     end
  #   end

  #   context "but does not implement #value" do
  #     class BadDoublerNoFormat
  #       def initialize(input)
  #       end

  #       def value
  #       end
  #     end

  #     let(:junk) { subject.junk [2], format: BadDoublerNoFormat }

  #     specify { expect { junk }.to raise_error("Formatter class must implement #format method") }
  #   end


  #   # BUG: this special case of format does not work:
  #   # doubled_string = junk 6, format: ->(x) { x * 2 })
  #   # expect(doubled_string.size).to eq(12) # nope, it's 6
  #   # junk 6, format: ->(x) { x.upcase } # also returns x unmodified

  #   context "when format is a Proc" do
  #     let(:junk) { subject.junk [3], format: ->(x) { x * 3 } }

  #     it "calls proc on junk value" do
  #       expect(junk).to eq(9)
  #     end
  #   end

  #   context "when format and exclude are used together" do
  #     let(:truth) { subject.junk :bool, format: :string, exclude: "false" }
  #     let(:lies) { subject.junk :bool, format: :string, exclude: truth }

  #     specify "it just works" do
  #       expect(truth).to eq("true")
  #       expect(lies).to eq("false")
  #     end
  #   end
  # end
end
