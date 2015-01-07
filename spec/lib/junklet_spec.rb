require 'spec_helper'

describe Junklet do
  specify { expect(Junklet).to be }

  let(:regex) { /-[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/ }
  
  junk_let :junk

  specify { expect(junk).to be }
  specify { expect(junk).to match /^junk-/ }
  specify { expect(junk).to match regex }
end
