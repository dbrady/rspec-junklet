require 'spec_helper'

# Because rspec-junklet extends RSpec, this spec file actually EXERCISES
# rspec-junklet instead of testing it directly. You can treat it like a list of
# examples or a cheatsheet for how to try things.

describe RSpec::Junklet do
  let(:hex_regex) { /[\da-f]{32}/ }

  describe '.junklet' do
    context "with a single arg" do
      junklet :trash

      specify { expect(trash).to be }
      specify { expect(trash).to match /^trash_/ }
      specify { expect(trash).to match hex_regex }

      describe "memoization" do
        specify { expect(trash).to eq(trash) }
      end
    end

    context "with multiple args" do
      junklet :trash, :toss, :crud, :crap

      # FIXME: if we were to stub out junk here, these examples
      # could be changed to read
      # expect(trash).to eq("trash_1234567809etc")
      # which would document the output MUCH more clearly
      specify { expect(trash).to match /^trash_/ }
      specify { expect(trash).to match hex_regex }
      specify { expect(toss).to match /^toss_/ }
      specify { expect(toss).to match hex_regex }
      specify { expect(crud).to match /^crud_/ }
      specify { expect(crud).to match hex_regex }
      specify { expect(crap).to match /^crap_/ }
      specify { expect(crap).to match hex_regex }
    end

    context 'with separator option' do
      junklet :host_name, separator: '-'
      junklet :last_name, :first_name, separator: '.'
      specify { expect(host_name).to match /^host-name-/ }
      specify { expect(host_name).to match hex_regex }
      specify { expect(last_name).to match /^last\.name\./ }
      specify { expect(last_name).to match hex_regex }
      specify { expect(first_name).to match /^first\.name\./ }
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

    context "with integer argument" do
      let(:little_trash) { junk 5 }
      let(:big_trash) { junk 100 }

      it "sizes junk to that many characters" do
        expect(little_trash.size).to eq(5)
        expect(big_trash.size).to eq(100)
      end

      it "returns hex chars of that length" do
        expect(little_trash).to match /^[\da-f]{5}$/
        expect(big_trash).to match /^[\da-f]{100}$/
      end
    end

    context "with type: array" do
      let(:junk_ray) { junk [:a, :b, :c] }
      it "returns a random element of the array" do
        expect([:a, :b, :c]).to include(junk_ray)
      end

      context "with excludes" do
        let(:junk_ray) { junk [:a, :b, :c], exclude: [:a, :b] }
        specify { expect(junk_ray).to eq(:c) }
      end
    end

    context "with type: range" do
      let(:junk_range) { junk 'a'..'c' }
      it "returns a random element of the range" do
        expect(%w[a b c]).to include(junk_range)
      end

      context "with excludes" do
        let(:junk_range) { junk 'a'..'c', exclude: ['a', 'b'] }
        specify { expect(junk_range).to eq('c') }
      end

      # TODO: Add the size feature after we commit to common formatting in junklet 3.0
      # context "with size" do
      #   let(:junk_range) { junk 'a'..'c', size: 2 }
      #   it "returns a consecutive string of the array elements from range" do
      #     expect(junk_range).to match(/[abc]{2}/)
      #   end
      # end
    end

    context "with type: Proc" do
      let(:junk_proc) { junk(->{ rand(3) }) }
      specify { expect([0,1,2]).to include(junk_proc) }

      context "with excludes" do
        let(:junk_proc) { junk(->{ rand(3) }, exclude: [0,2]) }
        specify { expect(junk_proc).to eq(1) }
      end
    end

    context "with type: enumerable" do
      let(:junk_list) { junk (0..3) }
      it "returns a random element of the array" do
        expect([0,1,2,3]).to include(junk_list)
      end
    end

    context "with type: :int" do
      let(:junk_integer) { junk :int }
      it "returns a random positive Fixnum" do
        expect { (junk_integer).to be_a Fixnum }
      end

      context "with min and max values" do
        let(:coin) { junk :int, min: 0, max: 1 }
        specify { expect([0,1]).to include(coin) }
      end

      context "with size" do
        let(:digit) { junk :int, size: 1 }
        specify { expect(digit).to be < 10 }
      end

      context "with exclude proc" do
        let(:junk_evens) { junk :int, min: 0, max: 10, exclude: ->(x) { x % 2 == 1 } }
        specify { expect(junk_evens % 2).to eq(0) }
      end
    end

    context "with type: :bool" do
      let(:junk_bool) { junk :bool }
      specify { expect([true, false]).to include(junk_bool) }

      context "with excludes" do
        let(:junk_bool) { junk :bool, exclude: true }
        specify { expect(junk_bool).to eq(false) }
      end
    end

    # begin
    #   $caught_bad_junklet_error = false
    #   junklet :cheesy_bad_junklet, cheese: true
    # rescue INVALID_JUNKLET_ERROR => e
    #   raise "junklet got invalid option" unless e.message == "junklet options must be one of #{VALID_JUNKLET_ARGS.map(&:inspect) * ', '}"
    #   $caught_bad_junklet_error = true
    # else
    #   raise "junklet got an invalid argument but didn't catch it" unless $caught_bad_junklet_error
    # end

    context "with exclude: val" do
      let(:heads) { 0 }
      let(:tails) { 1 }
      let(:coin_heads) { junk :int, max: 1, exclude: tails }
      let(:coin_tails) { junk :int, max: 1, exclude: heads }

      specify { expect(coin_heads).to eq(heads) }
      specify { expect(coin_tails).to eq(tails) }
    end

    # TODO: Formats here

    # format: :string -> calls .to_s
    # format: "format_string" -> calls sprintf(junkval, format_string)
    # format: Klass -> passes junkval to Klass.new
    # format: Proc -> passes junkval to Proc
    #
    # format: with exclude: - runs exclude AFTER running format. This is the whole point of formatters; it allows us to say junk().to_s, exclude: :otherval

  end

  context "metaprogramming use cases" do
    metaname = junk
    describe "works by allowing junk to be set from an ExampleGroup outside of an ExampleCase" do
      specify { expect(metaname).to be }
    end
  end
end
