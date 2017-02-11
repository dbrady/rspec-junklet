require PROJECT_ROOT + 'lib/rspec/junklet/junklet'

RSpec.configure do |config|
  config.extend(RSpec::Junklet::Junklet)    # This lets us say junklet() in describes and contexts
end

describe '.junklet' do
  junklet :pigs, :cows

  it "generates a let" do
    expect(pigs).to be
    expect(cows).to be
  end

  it "prefixes the let with its own name" do
    expect(pigs).to match /^pigs_/
    expect(cows).to match /^cows_/
  end

  it "appends 32 hex characters of random noise to make it unique" do
    expect(pigs).to match /^pigs_[0-9a-f]{32}$/
    expect(cows).to match /^cows_[0-9a-f]{32}$/
  end

  describe "separator option" do
    junklet :pigtruck, separator: '~'

    it 'uses separator instead of underscore' do
      expect(pigtruck).to match /^pigtruck~/
    end

    context "when junklet has underscores in its name" do
      junklet :http_get_param, separator: '-'

      it 'replaces underscores in junklet name as well' do
        expect(http_get_param).to match /^http-get-param-/
      end
    end
  end
end
