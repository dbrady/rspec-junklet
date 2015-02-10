require 'spec_helper'
require_relative '../../lib/line'

describe Line do
  let(:code)     { Line.new("  # Here's some code\n") }
  let(:let)      { Line.new("  let(:bob) { 'Bob McRobertson' } \n") }
  let(:uuid)     { Line.new("  let(:uuid)     { SecureRandom.uuid }\n") }
  let(:hex)      { Line.new("  let(:hex)      { SecureRandom.hex }\n") }
  let(:junklet)  { Line.new("  junklet :reggie\n") }
  let(:multi)    { Line.new("  junklet :john, :paul, :ringo, :the_other_one") }
  let(:blank)    { Line.new("\n") }
  let(:embedded) { Line.new('  let(:embedded)      { "www.#{SecureRandom.uuid}.com" }\n') }

  let(:uuid_arg) { Line.new('  let(:uuid_arg) { SecureRandom.uuid[0..10] }') }
  let(:hex_arg)  { Line.new('  let(:hex_arg) { SecureRandom.hex[0..10] }') }

  specify { code.should be_code }
  specify { code.should_not be_let }
  specify { code.should_not be_junklet }
  specify { code.names.should be_nil }
  specify { code.convert.should be_nil }

  specify { let.should_not be_code }
  specify { let.should be_let }
  specify { let.should_not be_junklet }
  specify { let.names.should eq([':bob']) }
  specify { let.convert.should be_nil }

  specify { uuid.should_not be_code }
  specify { uuid.should_not be_let }
  specify { uuid.should be_junklet }
  specify { uuid.convert.should eq(Line.new("  junklet :uuid")) }

  specify { junklet.should_not be_code }
  specify { junklet.should_not be_let }
  specify { junklet.should be_junklet }
  specify { junklet.names.should eq([':reggie']) }
  specify { junklet.convert.should eq(junklet) }

  specify { multi.should_not be_code }
  specify { multi.should_not be_let }
  specify { multi.should be_junklet }
  specify { multi.names.should eq([':john', ':paul', ':ringo', ':the_other_one']) }
  specify { multi.convert.should eq(multi) }

  specify { blank.should be_code }
  specify { blank.should_not be_let }
  specify { blank.should_not be_junklet }
  specify { blank.names.should be_nil }
  specify { blank.convert.should be_nil }

  specify { embedded.should_not be_code }
  specify { embedded.should be_let }
  specify { embedded.should_not be_junklet }
  specify { embedded.names.should eq([':embedded']) }
  specify { embedded.convert.should be_nil }

  specify { hex.should_not be_code }
  specify { hex.should_not be_let }
  specify { hex.should be_junklet }
  specify { hex.names.should eq([':hex']) }
  specify { hex.convert.should eq("  junklet :hex") }

  specify { uuid_arg.should_not be_code }
  specify { uuid_arg.should be_let }
  specify { uuid_arg.should_not be_junklet }
  specify { uuid_arg.names.should eq([':uuid_arg']) }
  specify { uuid_arg.convert.should be_nil }

  specify { hex_arg.should_not be_code }
  specify { hex_arg.should be_let }
  specify { hex_arg.should_not be_junklet }
  specify { hex_arg.names.should eq([':hex_arg']) }
  specify { hex_arg.convert.should be_nil }

end
