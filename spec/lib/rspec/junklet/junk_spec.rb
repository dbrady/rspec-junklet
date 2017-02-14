require 'spec_helper'
require PROJECT_ROOT + 'lib/rspec/junklet/junk.rb'
require PROJECT_ROOT + 'lib/rspec/junklet/generator.rb'

RSpec.configure do |config|
  config.extend(RSpec::Junklet::Junk)    # This lets us say junk() in describes and contexts
  config.include(RSpec::Junklet::Junk)    # This lets us say junk() in describes and contexts
end

class CycleGenerator < RSpec::Junklet::Generator
  def initialize(options={})
    min = options[:min] || 1
    max = options[:max] || 3
    @gen = (min..max).cycle
  end

  def call
    @gen.next
  end
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
      expect(val).to be_in [false, true]
    end
  end

  describe "junk(<Array>)" do
    let(:options) { [:a, :b, 3] }
    let(:val) { junk options }

    it "returns an element of the collection" do
      expect(val).to be_in options
    end
  end

  describe "junk(<Enumerable>)" do
    let(:options) { (1..5) }
    let(:val) { junk options }

    it "returns an element of the collection" do
      expect(val).to be_in options
    end

    it "calls #.to_a on the Enumerable" do
      # This expectation is included to document that this happens, and could
      # potentially cause a memory problem. Don't do junk (1..1_000_000_000_000)
      # unless you're all done with having memory.
      expect(options).to receive(:to_a).and_call_original
      expect(val).to be_in options
    end
  end

  describe "junk(<Proc>)" do
    let(:proc) { ->{ [1,2,3].sample } }
    let(:val) { junk proc }

    it "evaluates the proc" do
      expect(proc).to receive(:call).and_call_original
      expect(val).to be_in [1,2,3]
    end
  end

  describe "junk(<Symbol>)" do
    context "when <Symbol> is not a defined generator" do
      it "raises JunkletTypeError" do
        expect { junk :arglebargle }.to raise_error(JunkletTypeError, /Unrecognized junk type: 'arglebargle'/)
      end
    end

    context "when <Symbol> is defined as a Proc generator" do
      proc = ->{ [1,2,3].sample }
      define_junklet :test_123, proc
      let(:val) { junk :test_123 }

      it "evaluates the proc" do
        expect(val).to be_in [1, 2, 3]
      end
    end
  end

  describe ".define_junklet" do
    context "when <Symbol> is redefined" do
      define_junklet :test_bad, -> { rand }

      it "raises JunkletTypeError" do
        expect { instance_eval "define_junklet :test_bad, -> { rand * 2 }" }
          .to raise_error(JunkletTypeError, /Junk type 'test_bad' has already been registered/)
      end
    end

    # define_junklet occers at spec *definition* time, and is NOT SCOPED. If you
    # define a junklet anywhere in your suite, it will be defined before ANY
    # spec is run, much like a before(:all) scope. It will also be defined for
    # ALL specs, so you cannot define a junklet with the same name twice. It is
    # vital to remember that define_junklet is for naming VERY GENERIC TYPES of
    # junk; if you want to specialize it, use options to pass into the junklet
    # after it is defined.
    context "defines junklet regardless of scope" do
      $first = "first"

      # ----------------------------------------------------------------------
      # BEGIN FIRST COPY OF THIS SPEC (which might get run first!)  This context
      # appears twice, and is a duplicate. But RSpec may run either one first
      # (because order=random), hence all this nonsense about whether $first is
      # first and or $first is second
      context "when a duplcate junklet is defined the first time in the spec" do
        context "and this context is run #{$first}" do
          if $first == "first"
            $first = "later"
            let(:val) { junk :type_unrepeatable }
            it "defines a junklet just fine" do
              instance_eval "define_junklet :type_unrepeatable, ->{42}"
              expect(val).to eq 42
            end
          else
            let(:val) { junk :type_unrepeatable }
            it "raises JunkletTypeError" do
              expect { instance_eval "define_junklet :type_unrepeatable, ->{42}" }
                .to raise_error(JunkletTypeError, "Junk type 'type_unrepeatable' has already been registered")
            end
          end
        end
      end
      # END FIRST COPY OF THIS SPEC
      # ----------------------------------------------------------------------

      # ----------------------------------------------------------------------
      # BEGIN SECOND COPY OF THIS SPEC (which might get run first!)
      # This context appears twice, and is a duplicate. But RSpec may run either
      # one first, hence all this nonsense about whether $first is first and or
      # $first is second
      context "when a duplcate junklet is defined a second time in the spec" do
        context "and this context is run #{$first}" do
          if $first == "first"
            $first = "later"
            let(:val) { junk :type_unrepeatable }
            it "defines a junklet just fine" do
              instance_eval "define_junklet :type_unrepeatable, ->{42}"
              expect(val).to eq 42
            end
          else
            let(:val) { junk :type_unrepeatable }
            it "raises JunkletTypeError" do
              expect { instance_eval "define_junklet :type_unrepeatable, ->{42}" }
                .to raise_error(JunkletTypeError, "Junk type 'type_unrepeatable' has already been registered")
            end
          end
        end
      end
      # END SECOND COPY OF THIS SPEC
      # ----------------------------------------------------------------------
    end
  end

  describe "define_junklet(<bool>)" do
    define_junklet :cointoss, :bool
    let(:toss) { junk :cointoss }
    let(:obverse) { junk :cointoss, exclude: toss }

    it "generates junk according to the boolean type" do
      expect(toss).to be_in [true, false]
    end

    it "allows lets to use options" do
      expect(obverse).to eq !toss
    end
  end

  context "when define_junklet applies constraints" do
    it "those constraints are honored"
    context "when constraints are applied to the junk" do
      it "they override the junklet consstraints"
    end

    context "when a new junklet is defined based on the previous one" do
      it "honors the existing constraints"
      context "and that new junklet overrides the original constraints" do
        it "honors the overridden constraints"
        context "when constraints are applied to the junk" do
          it "they override all constraints hitherto applied"
        end
      end
    end
  end

  describe "junk(<Generator>)" do
    context "when generator is passed straight in as an instance" do
      let(:generator) { CycleGenerator.new }
      let(:val) { junk generator }

      it "generates junk by sending #call" do
        # remember it's cached by the let
        expect(generator).to receive(:call).exactly(:once).and_call_original
        expect(val).to eq 1
        expect(val).to eq 1
      end
    end

    context "when enerator is passed straight in as a class" do
      let(:val) { junk CycleGenerator, min: 7, max: 10 }

      before do
        expect(CycleGenerator)
          .to receive(:new)
               .with({min: 7, max: 10})
               .and_call_original
      end

      it "creates an instance with .new(options), then sends it #call" do
        expect(val).to eq 7
      end
    end

    # context "when generator is defined as junk" do
    #   define_junklet :test123, CycleGenerator

    #   let(:val) { junk :test123 }

    #   it "generates junk by sending #call" do
    #     expect(val).to eq 1
    #     expect(val).to eq 2
    #     expect(val).to eq 3
    #     expect(val).to eq 1
    #   end
    # end
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

  # describe "#define_junklet" do
  #   it "passes options to Generator.new" do
  #     instance_eval "undefine_junklet :test_123"
  #     expect(CycleGenerator)
  #       .to receive(:new)
  #            .with( {min: 3, max: 5 } )
  #            .and_call_original
  #     instance_eval"define_junklet :test_123, CycleGenerator.new"
  #     instance_eval "junk :test_123, min: 3, max: 5"
  #     # TODO: Make this work, but then... ugh. What about "junk :test_123, min: 5", e.g. adding/extending/changing options
  #     # We're close but the metaphor isn't *quite* right
  #   end
  # end
end
