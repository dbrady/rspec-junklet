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

end
