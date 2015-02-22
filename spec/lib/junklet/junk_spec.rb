require 'spec_helper'
require_relative '../../../lib/junklet/junk'

class JunkSpy
  attr_reader :lets

  include ::Junklet::Junk
end

describe JunkSpy do
  let(:junk) { subject.junk }
  let(:hex_regex) { /^[0-9a-f]+$/ }

  specify { expect(junk).to match(hex_regex) }
  specify { expect(junk.size).to eq(32) }

  specify "it is random each time" do
    expect(subject.junk).to_not eq(subject.junk)
  end

  describe "#junk(size)" do
    let(:junk) { subject.junk 14 }

    specify { expect(junk).to match(hex_regex) }
    specify { expect(junk.size).to eq(14) }
  end

  describe "#junk(type)" do
    context "when type is :int" do
      let(:junk) { subject.junk :int }
      specify { expect(junk).to be_kind_of(Fixnum) }

      context "with min or max option" do
        let(:junk) { subject.junk :int, min: 3, max: 5 }
        it "constrains the value" do
          expect([3,4,5]).to include(junk)
        end
      end

      context "with size option" do
        let(:junk) { subject.junk :int, size: 4 }
        it "constrains the value" do
          expect((1000..9999)).to include(junk)
        end
      end
    end

    context "when type is :bool" do
      let(:junk) { subject.junk :bool }

      it "returns a boolean" do
        expect([false, true]).to include(junk)
      end
    end

    context "when type is Array or Enumerable" do
      let(:junk) { subject.junk [:a, :b, 3] }

      specify { expect([:a, :b, 3]).to include(junk) }
    end

    context "when type is Proc" do
      let(:junk) { subject.junk ->{ [1,2,3].sample } }

      specify { expect([1,2,3]).to include(junk) }
    end
  end

  context "with exclude option" do
    context "when excluding an item" do
      let(:junk) { subject.junk :int, max: 1, exclude: 1 }

      specify { expect(junk).to eq(0) }
    end

    context "when excluding an array" do
      let(:junk) { subject.junk :int, max: 10, exclude: [1,3,5,7,9] }

      specify { expect([0,2,4,6,8,10]).to include(junk) }
    end

    context "when excluding an enumerable" do
      let(:junk) { subject.junk :int, max: 10, exclude: 1.step(10, 2) }

      specify { expect([0,2,4,6,8,10]).to include(junk) }
    end

    context "when excluding a Proc" do
      let(:junk) { subject.junk :int, max: 10, exclude: ->(x) { x%2==1 } }
      specify { expect([0,2,4,6,8,10]).to include(junk) }
    end
  end

  context "with format option" do
    context "when format is :string" do
      let(:junk) { subject.junk :int, max: 0, format: :string }

      specify { expect(junk).to eq("0") }
    end

    context "when format is :int" do
      let(:junk) { subject.junk ["42"], format: :int }

      specify { expect(junk).to be_kind_of(Integer) }
      specify { expect(junk).to eq(42) }
    end

    context "when format is a format string" do
      let(:junk) { subject.junk [15], format: "0x%02x" }

      it "formats the value by the string" do
        expect(junk).to eq("0x0f")
      end
    end

    context "when format is a Junklet::Formatter" do
      class HexTripler < Junklet::Formatter
        def value
          input * 3
        end

        def format
          "0x%02x" % value
        end
      end

      let(:junk) { subject.junk [4], format: HexTripler }

      it "delegates to #format" do
        expect(junk).to be_kind_of(String)
        expect(junk).to eq("0x0c")
      end
    end

    context "when format is a class that quacks like Junklet::Formatter" do
      class HexDoubler
        def initialize(input)
          @n = input
        end

        def value
          @n * 2
        end

        def format
          "0x%04x" % value
        end
      end

      let(:junk) { subject.junk [12], format: HexDoubler }

      it "works as expected" do
        expect(junk).to be_kind_of(String)
        expect(junk).to eq("0x0018")
      end
    end

    context "but does not implement #value" do
      class BadDoublerNoFormat
        def initialize(input)
        end

        def value
        end
      end

      let(:junk) { subject.junk [2], format: BadDoublerNoFormat }

      specify { expect { junk }.to raise_error("Formatter class must implement #format method") }
    end


    context "when format is a Proc" do
      let(:junk) { subject.junk [3], format: ->(x) { x * 3 } }

      it "calls proc on junk value" do
        expect(junk).to eq(9)
      end
    end

    context "when format and exclude are used together" do
      let(:truth) { subject.junk :bool, format: :string, exclude: "false" }
      let(:lies) { subject.junk :bool, format: :string, exclude: truth }

      specify "it just works" do
        expect(truth).to eq("true")
        expect(lies).to eq("false")
      end
    end
  end
end
