require 'spec_helper'
require_relative '../../lib/junklet_upgrade_parser'


describe JunkletUpgradeParser do
  specify { expect(JunkletUpgradeParser).to be }

  let(:parser) { JunkletUpgradeParser.new }

  # Process test files
  context "with test fixtures" do
    # TODO: Mothballing upgrader for now. Embedded gives a good
    # example of how the parser is fascinatingly broken.
    #%w(block1 mixed_code combined old_skool embedded).each do |name|
    %w(block1 mixed_code combined old_skool).each do |name|
      describe "processing #{name}_before.txt -> #{name}_after.txt" do
        let(:fixture_path) { File.expand_path(File.join(File.dirname(__FILE__), '../fixtures')) }
        let(:lines) { IO.readlines("#{fixture_path}/#{name}_before.txt") }
        let(:output_file) { "#{fixture_path}/#{name}_after.txt" }
        let(:output_lines) { IO.readlines(output_file) }

        specify { expect(parser.upgraded_lines(lines)).to eq(output_lines) }
        specify { expect(parser.upgraded_lines(lines) * '').to eq(File.read(output_file)) }

        # This dumps a purty colorized diff of what we expected to get
        # on the left against what we actually got on the right. It's
        # a very helpful visual aid when the spec is acting up. It's a
        # fork in the eyeballs* if you just want to see green dots.
        #
        # * two forks, if you're into async
        # it "dumps the file diff (no-op spec)" do
        #   parsed_lines = parser.upgraded_lines(lines)

        #   puts '-' * 80
        #   dump_diff(output_lines, parser.upgraded_lines(lines))
        #   puts '-' * 80
        #   puts parser.inspect
        # end
      end
    end
  end

  # TODO: replace this with a hash of line => replacement pairs and a single spec
  describe '#parse_line' do
    context 'when line contains no SecureRandom.uuid or SecureRandom.hex calls' do
      let(:line) { SecureRandom.hex(100) }
      specify { expect(subject.parse_line(line)).to eq(line) }
    end

    # context "when line contains SecureRandom.hex(int)" do
    #   let(:line) { '    emit_noise("#{SecureRandom.hex(12)")' }
    #   it { pending "write me you clods" }
    # end

    # context "when line contains SecureRandom.hex int" do
    #   it { pending "write me you clods" }
    # end

    [:hex, :uuid].each do |method|
      context "when line contains SecureRandom.#{method}" do
        let(:line) { "        let(:extra_fields) { Array.new(2) { SecureRandom.#{method} }  }" }
        it "replaces SecureRandom.#{method} with junk" do
          expect(parser.parse_line(line)).to eq('        let(:extra_fields) { Array.new(2) { junk }  }')
        end
      end

      context "when extra whitespace is present around SecureRandom.#{method}" do
        let(:line) { "        let(:extra_fields) { Array.new(2) {      SecureRandom.#{method}  }  }" }
        it "replaces SecureRandom.#{method} with junk" do
          expect(parser.parse_line(line)).to eq('        let(:extra_fields) { Array.new(2) {      junk  }  }')
        end
      end

      context "when line contains SecureRandom.#{method}[range]" do
        context "and range is [int..int] (e.g. [0..10])" do
          let(:line) { "question_id: SecureRandom.#{method}[0..10]" }
          it "replaces SecureRandom.#{method}[0..10] with junk(10)" do
            expect(parser.parse_line(line)).to eq('question_id: junk(10)')
          end
        end

        context "and range is of form [n..int]" do
          let(:line) { "question_id: SecureRandom.#{method}[3..10]" }
          it "replaces SecureRandom.#{method}[0..10] with junk(7)" do
            expect(parser.parse_line(line)).to eq('question_id: junk(7)')
          end
        end

        context "and range is [0..var] (e.g. [0..MAX_QUESTION_ID_LEN-1]" do
          let(:line) { "SecureRandom.#{method}[0..Mogrifier::NcpdpScriptStandard::MAX_QUESTION_ID_LEN-1]" }
          it "replaces SecureRandom.#{method}[0..n] with junk(n)" do
            expect(parser.parse_line(line)).to eq('junk(Mogrifier::NcpdpScriptStandard::MAX_QUESTION_ID_LEN-1)')
          end
        end
        # TODO: three-dot ranges not yet supported due to rarity.
      end
    end
  end
end
