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
        expect(odd_enum).to receive(:include?).at_least(:once).and_call_original
        expect(val).to be_in even_numbers
      end
    end

    context "when excluding a Proc" do
      let(:generator) { [1,3,5,6].to_enum }
      let(:generator_proc) { -> { generator.next } }
      let(:odd_excluder_proc) { ->(x) { x % 2 == 1 } }
      let(:val) { junk generator_proc, exclude: odd_excluder_proc }

      it "excludes the candidate if the proc returns true" do
        expect(val).to eq 6
      end

      it "passes the junk candidates to the proc" do
        expect(odd_excluder_proc).to receive(:call).with(1).and_call_original # rejected
        expect(odd_excluder_proc).to receive(:call).with(3).and_call_original # rejected
        expect(odd_excluder_proc).to receive(:call).with(5).and_call_original # rejected
        expect(odd_excluder_proc).to receive(:call).with(6).and_call_original # accepted
        expect(val).to eq 6
      end
    end
  end

  describe "format option" do
    context "when format is :string" do
      it "returns the junk cast to a string" do
        expect(junk [42], format: :string).to eq "42"
      end

      let(:item) { double }
      let(:generator) { [item] }
      let(:val) { junk generator, format: :string }

      it "sends #to_s to the junk to convert it" do
        expect(item).to receive(:to_s).and_return "42"
        expect(val).to eq "42"
      end
    end

    # Why is this even here, it never gets used...
    context "when format is :int" do
      it "returns the junk cast to an integer" do
        expect(junk ["42"], format: :int).to eq 42
      end

      let(:item) { double }
      let(:generator) { [item] }
      let(:val) { junk generator, format: :int }

      it "sends #to_i to the junk to convert it" do
        expect(item).to receive(:to_i).and_return 42
        expect(val).to eq 42
      end
    end

    context "when format is a sprintf-style format string" do
      let(:binary_string) { junk :int, format: "%b" }

      it "formats the generated junk with the format string" do
        expect(binary_string).to match /^[01]+$/
      end

      context "when generator emits an array" do
        let(:generator) { ->{ [2017, 1, 9] } }
        let(:val) { junk generator, format: "%d-%02d-%02d" }

        it "passes all of the array elements to the format string" do
          expect(val).to eq "2017-01-09"
        end
      end
    end

    context "when fromat is a custom Junklet::Formatter class" do
      # By inheriting from Formatter, we get new(input) for free
      class HexTripler < RSpec::Junklet::Formatter
        def format
          "0x%02x" % (input * 3)
        end
      end

      let(:val) { junk [14], format: HexTripler }

      it "passes junk to new and calls format" do
        expect(val).to eq "0x2a"
      end
    end

    context "when format is a any class that implements .new(junk) and #format" do
      class HexDoubler
        def initialize(input)
          @n = input
        end

        def format
          "0x%02x" % (@n * 2)
        end
      end

      let(:val) { junk [14], format: HexDoubler }

      it "passes junk to new and calls format" do
        expect(val).to eq "0x1c"
      end
    end

    context "when format is a Proc" do
      let(:val) { junk [14], format: ->(x) { x.to_s(2) } }

      it "formats the junk through the proc" do
        expect(val).to eq "1110"
      end

      context "when generator emits an array" do
        let(:generator) { ->{ [2017, 1, 9] } }
        let(:val) { junk generator, format: ->(x) { "%d-%02d-%02d" % x } }

        it "passes all of the array elements to the format string" do
          expect(val).to eq "2017-01-09"
        end
      end
    end
  end

  describe "format and exclude used together" do
    let(:truth) { junk :bool, format: :string, exclude: "false" }
    let(:lies) { junk :bool, format: :string, exclude: truth }

    it "applies exclusion after formatting" do
      expect(truth).to eq("true")
      expect(lies).to eq("false")
    end
  end
end
