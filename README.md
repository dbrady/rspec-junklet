# Junklet

Create tiny chunks of unique junk data in RSpec with `junk_let :name`.

Junklet data is fixture data that:

* We essentially don't care about,
* But we might want to test for equality somewhere later,
* And we might need to be unique between runs in case a spec crashes
and SQLServer fails to clean up the test database

So,

* We want it to be easy to create junk data fields quickly and easily,
  and
* If equality fails we want to be led to the offending field by the
  error message and not just the line number in the stack trace.

# Background

At CoverMyMeds we have a legacy impingement that prevents us sometimes
from clearing out data from previous test runs. As a result we often
have required fields in tests that must be unique but are tested
elsewhere, so we don't really care about them in the current test
run. For the current test we just want to stub out that field with
something unique but we also want to communicate to the developer that
the contents of the field are not what we currently care about.

Currently we do this with `SecureRandom.uuid`, so we'll see code like
this frequently in RSpec:

```ruby
let(:first_name) { SecureRandom.uuid }
let(:last_name) { SecureRandom.uuid }
let(:address) { SecureRandom.uuid }
let(:city) { SecureRandom.uuid }
let(:state) { SecureRandom.uuid }
let(:phone) { SecureRandom.uuid }
```

...etc. Later in the spec we'll often test against those stubs,
e.g. with `expect(user.first_name).to eq(first_name)` but this idiom
expresses that we only care about the equality, not the actual
contents.

Junklet seeks to improve the readability and conciseness of this
intention. One thing that bugs me about the above approach is that if
a weird regression bug appears and an unimportant field is the source
of a crash. So with Junklet I also wanted to add the ability to call
out the offending field by name. In theory we could just write
`let(:first_name) { 'first_name-' + SecureRandom.uuid }` but in
practice that creates duplication in the code and muddies the original
idiom of "uncared-about" data.

Enter Junklet:

```ruby
junk_let :first_name
junk_let :last_name
junk_let :address
junk_let :city
junk_let :state
junk_let :phone
```

Or, if you don't want the junk_lets to sprawl vertically,

```ruby
junk_let :first_name, :last_name, :address, :city, :state, :phone
```

This will have the same effect as calling `let` on the named fields
and setting the fieldname and a UUID to be the memoized value.

No, `junk_let!` is NOT also included here because it doesn't really
make sense until and unless we write custom generators.

# TODO

* Formats - The original motivation for Junklet is to encapsulate the
  SecureRandom.uuid code into something meaningful and
  intention-revealing. However, it only works for strings with no
  formatting. If you have a field that DOES have a formatting
  requirement, then you have to fall back on a real `let`
  statement. I'd like Junklet to be able to provide common formatters
  and/or accept formatters for fields with special values or
  formats. So an email address could look like
  'email-junkuser@#{uuid}.com', or a currency field could contain a
  random value from $0.00 to $99,999,999.00 (or some other equally
  reasonable upper limit). A small signed int could contain -128 to
  127 and even a boolean could contain a random true/false value. You
  could argue that this starts to lead towards nondeterministic tests
  but the reality is the started heading there when we first started
  making calls to SecureRandom. My thinking is that a call to
  `junk_let` could accept an optional hash and/or block that defines a
  formatter and/or generator, and/or the configuration for Junklet
  could accept definitions of domain-specific formatters that you want
  to reuse throughout your project.

* True cucumber features - RSpec is tested with cucumber features that
  express blocks of RSpec and then evaluate that the specs did what
  was intended. The existing spec suite merely uses junklets and then
  tests their side effects.

* RSpec 3.x support - Ideally the mechanism for adding the `junk_let`
  method is the same, but if not then a separate version would be nice
  for building and testing RSpec 3 vs. 2. We need to support both, but
  at the time of this writing the most pressing need is for
  RSpec 2. Remember kids, "Enterprise" means "most of our money comes
  from the legacy platform".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'junklet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install junklet

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/junklet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
