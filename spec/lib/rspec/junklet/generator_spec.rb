require 'spec_helper'
require PROJECT_ROOT + 'lib/rspec/junklet/generator.rb'

module RSpec
  module Junklet
    class SequenceGen < Generator
      def initialize(options={})
        @gen = [1,2,3].cycle
      end

      def call
        @gen.next
      end
    end

    describe Generator do
      describe "#call" do
        let(:generator) { SequenceGen.new }

        it "generates a junk element" do
          expect(generator.call).to eq 1
          expect(generator.call).to eq 2
          expect(generator.call).to eq 3
          expect(generator.call).to eq 1
        end
      end
    end
  end
end
