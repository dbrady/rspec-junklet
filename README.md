# Junklet

Cache tiny chunks of unique junk data in RSpec with `junklet :name`;
get handy clumps of junk data at any time with `junk`. Size your junk
with e.g. `junk 100` or `junk 4`.

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

# If You Work At CMM

1. junklet means never having to type SecureRandom again.
1. junklet prepends the field name to make errors easier to read.
1. junk() returns a 32-byte random hex number, junk(n) returns the
   same thing, only n bytes long (can be longer than 32)

Instead of writing this -> write this:

* `let(:pants) { SecureRandom.uuid }` -> `junklet :pants`
* `let(:host_name) { "host-name-#{SecureRandom.uuid}" }` -> `junklet :host_name, separator: '-'` (Remember that underscores aren't legal in host names)
* `let(:bad_number) { SecureRandom.hex[0..7] }` -> `let(:bad_number) { junk 8 }`
* `let(:website) { "www.#{SecureRandom.hex}.com" }` -> `let(:website) { "www.#{junk}.com }`


# Usage

    junklet :var [, :var_2 [...]] [, options_hash]

    junklet :first_name

Creates a `let :first_name` with the value of
`first_name-774030d0f58d4f588c5edddbdc7f9580` (the hex number is a
uuid without hyphens and will change with each test case, not just
each test run)

    junklet :host_name, separator: '-'

Creates a `let :host_name`, but changes underscores to hyphens in the
string value,
e.g. `host-name-774030d0f58d4f588c5edddbdc7f9580`. Useful
specifically for host names, which cannot have underscores in them.

    junklet :a_a, :b_b, :c_c, separator: '.'

Does what it says on the tin: creates 3 items with string values of
`a.a`, `b.b`, and `c.c` respectively.


    junk [length=32]

Can be called from inside a spec or let block, and returns a random
hex string 32 bytes long (or whatever length you specify)

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
junklet :first_name
junklet :last_name
junklet :address
junklet :city
junklet :state
junklet :phone
```

Or, if you don't want the junklets to sprawl vertically,

```ruby
junklet :first_name, :last_name, :address, :city, :state, :phone
```

This will have the same effect as calling `let` on the named fields
and setting the fieldname and a 32-byte hex string (a uuid with
hyphens removed) to be the memoized value.



# Finer Control / Custom Types

The `junk` method now has MUCH finer-grained control, though this
hasn't been pushed up to junklet yet.


`junk <type> [options]`

```ruby
junk(:int) # returns a random, positive ruby Fixnum between 0 and
           # 2**62-1.
junk(:int, min: 5, max: 9) # returns a number from 5 to 9
junk(:int, max: 1) # returns 0 or 1

junk(:bool) # returns true or false

junk([:a, :b, :c]) # samples from the Array
junk(('A'..'Z')) # samples from the range.

# Memory warning: calls to_a on range first, so if you want a number
# from 100000 to 999999, favor junk(:int, min: 100000, max: 999999)
# instead.

junk ->{ your_own_random_thing_here }

# Also note that all types also take an `exclude` option, which can be
# a value, an array, or a proc. These all return even numbers:

junk :int, min: 2, max:   4, exclude: 3
junk :int, min: 2, max:  10, exclude: [3,5,7,9]
junk :int, min: 2, max: 100, exclude: ->(x) { x % 2 == 1 }

# And remember that junk is at the same level of precedence as let, so
# the following ALSO return even numbers:

let(:three) { 3 }
let(:evens) { junk :int, min: 2, max:   4, exclude: three }
let(:two_or_four) { junk :int, min: 2, max:   4, exclude: ->(x){ !evens.include?(x) }

```

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
  `junklet` could accept an optional hash and/or block that defines a
  formatter and/or generator, and/or the configuration for Junklet
  could accept definitions of domain-specific formatters that you want
  to reuse throughout your project.

* True cucumber features - RSpec is tested with cucumber features that
  express blocks of RSpec and then evaluate that the specs did what
  was intended. The existing spec suite merely uses junklets and then
  tests their side effects.

* RSpec 3.x support - Ideally the mechanism for adding the `junklet`
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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/junklet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Write specs to document how your change is to be used
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
