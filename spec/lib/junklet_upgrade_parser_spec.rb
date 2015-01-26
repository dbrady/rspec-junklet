require 'spec_helper'
require_relative '../../lib/junklet_upgrade_parser'


describe JunkletUpgradeParser do
  specify { expect(JunkletUpgradeParser).to be }

  let(:parser) { JunkletUpgradeParser.new }

  # Process test files
  context "with test fixtures" do
    %w(block1 mixed_code combined old_skool).each do |name|
      describe "processing #{name}_before.txt -> #{name}_after.txt" do
        let(:fixture_path) { File.expand_path(File.join(File.dirname(__FILE__), '../fixtures')) }
        let(:lines) { IO.readlines("#{fixture_path}/#{name}_before.txt") }
        let(:output_file) { "#{fixture_path}/#{name}_after.txt" }
        let(:output_lines) { IO.readlines(output_file) }

        specify { expect(parser.upgraded_lines(lines)).to eq(output_lines) }
        specify { expect(parser.upgraded_lines(lines) * '').to eq(File.read(output_file)) }
        
        # it "dumps the file diff (no-op spec)" do
        #   parsed_lines = parser.upgraded_lines(lines)
        #   puts '-' * 80
        #   puts lines
        #   dump_diff(output_lines, parser.upgraded_lines(lines))
        #   puts parser.inspect
        # end
      end
    end
  end

  describe "#imblart_line" do
  end
end
