require PROJECT_ROOT + 'lib/rspec/junklet/junklet'

class JunkletSpy
  attr_reader :lets

  include ::RSpec::Junklet::Junklet

  def let(*args)
    @lets = args
  end

  def junk
    'junkety_junky_junk'
  end
end

describe JunkletSpy do
  specify { expect(subject).to respond_to(:junklet) }

  describe '.junklet' do
    it 'delegates named junklets to let' do
      expect(subject).to receive(:let).with(:pigs)
      expect(subject).to receive(:let).with(:cows)
      subject.junklet :pigs, :cows
    end

    it 'delegates junk generation to junk' do
      expect(subject).to receive(:make_junklet).with(:pig_truck, 'pig_truck', '_', 'junkety_junky_junk')
      expect(subject).to receive(:make_junklet).with(:cow_truck, 'cow_truck', '_', 'junkety_junky_junk')
      subject.junklet :pig_truck, :cow_truck
    end

    context "with separator" do
      it 'converts separator in name' do
        expect(subject).to receive(:make_junklet).with(:pig_truck, 'pig~truck', '~', 'junkety_junky_junk')
        expect(subject).to receive(:make_junklet).with(:cow_truck, 'cow~truck', '~', 'junkety_junky_junk')
        subject.junklet :pig_truck, :cow_truck, separator: '~'
      end
    end
  end
end
