# Junklet

Cache tiny chunks of unique junk data in RSpec with `junklet :name`; get handy
clumps of junk data at any time with `junk`. Size your junk with e.g. `junk 100`
or `junk 4`.

Junklet data is fixture data that:

* We essentially don't care about,
* But we might want to test for equality somewhere later,
* And we might need to be unique between runs in case a spec crashes and
SQLServer fails to clean up the test database

So,

* We want it to be easy to create junk data fields quickly and easily, and
* If equality fails we want to be led to the offending field by the error
  message and not just the line number in the stack trace.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-junklet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-junklet

# Usage

junklet adds two keywords to RSpec's DSL: `junklet`, which defines a `let`
statement containing junk data, and `junk`, which is a method that returns many
and varied types of junk data. The former is meant to be used as part of the DSL
to declare pieces of data to be junk, while the latter is intended to be used
anywhere inside RSpec to supply the junk data itself.

To illustrate, these statements are functionally identical:

```ruby
junklet :pigtruck
let(:pigtruck) { junk }
```

## Junklet

`junklet` declares a memoized variable containing random junk.

    junklet :var [, :var_2 [...]] [, options_hash]

So, for example,

    junklet :first_name

Creates a `let :first_name` with the value of
`first_name-774030d0f58d4f588c5edddbdc7f9580` (the hex number is a uuid without
hyphens and will change with each test _case_, not just each test run).

Currently the options hash only gives you control over the variable names appear
in the junk data, not the junk data itself. For example,

```ruby
junklet :host_name, separator: '-'
```

Creates a `let :host_name`, but changes underscores to hyphens in the string
value, e.g. `host-name-774030d0f58d4f588c5edddbdc7f9580`. Useful specifically
for host names, which cannot have underscores in them.

```ruby
junklet :a_a, :b_b, :c_c, separator: '.'
```

Does what it says on the tin: creates 3 items with string values of
`a.a.774...`, `b.b.1234...`, and `c.c.234abc...` respectively. I don't know why
you'd need this, but hey, if you do there it is.

## Junk

`junk` returns random junk, which can be finely tuned and fiddled with.

```ruby
junk
junk (integer|symbol|enumerable|proc) [options]
```

By default, just calling `junk` from inside a spec or let block returns a random
hex string 32 bytes long.

### integer

Give junk an integer argument and it will return that many hexadecimal digits of
junk data. Note that this is HALF the number of digits returned if you were to
call `SecureRandom.hex(n)`, because `hex(n)` returns n _bytes_, each of which
requires two hex digits to represent. Since we're more concerned about specific
byte lengths, `junk(n)` gives you n digits, not n*2 digits representing n bytes.


```ruby
junk 17 - return 17 bytes of junk data
```

### symbol

junk may be given a symbol denoting the type of data to be returned. Currently
`:int` and `:bool` are the only supported types. `junk :bool` merely returns
true or false; `junk :int` is much more complicated and interesting.

```ruby
junk :bool # Boring. Well, 50% chance of boring.
```

`junk :int` is the most complicated and/or interesting type of junk. It returns
a random decimal number, and it has the most options such as `size` (number of
digits), and `min` and `max` (which sort of do what you'd expect).

By default, `junk :int` returns a random number from 0 to the largest possible
`Fixnum`, which is 2**62-1.

```ruby
junk :int # return a random integer from 0 to 2**62-1 (maximum size of
a Fixnum)
```

`size`, `min` and `max` control the size and bounds of the random number.

```ruby
junk :int, size: 3 # returns a 3-digit decimal from 100 to 999.
junk :int, max: 10 # returns a random number from 0 to 10.
junk :int, min: 100 # returns a random number from 100 to 2**62-1.
```

Note: You can mix size with min or max, but they can only be used to further
restrict the range, not expand it, because that would change the size
constraint. So these examples work the way you'd expect:

```ruby
junk :int, size: 4, min: 2000 # random number 2000-9999
junk :int, size: 4, max: 2000 # random number 1000-2000
```

But in these examples, `min` and `max` have no effect:

```ruby
junk :int, size: 2, min: 0 # nope, still gonna get 10-99
junk :int, size: 2, max: 200 # nope, still gonna get 10-99
```

Technically, you CAN use BOTH `min` and `max` with `size` to constrain both
bounds of the number, but this effectively makes the `size` option redundant. It
will work correctly, but if you remove the size constraint you'll still get the
same exact range:

```ruby
# Don't do this - size argument is redundant
junk :int, size: 3, min: 125, max: 440 # 125-440. size is now redundant.
```

### Array / Enumerable

If you give junk an `Array`, `Range`, or any other object that implements
`Enumerable`, it will select an element at random from the collection.

```ruby
junk [1,3,5,7,9] # pick a 1-digit odd number
junk (1..5).map {|x| x*2-1 } # pick a 1-digit odd number while trying way too hard
junk (1..9).step(2) # pick a 1-digit odd number, but now I'm just showing off
```

*IMPORTANT CAVEAT*: the Enumerable forms all use `.to_a.sample` to get the
random value, and `.to_a` will cheerfully exhaust all the memory Ruby has if you
use it on a sufficiently large array.

*LESS-IMPORTANT CAVEAT*: Technically anything that can be converted to an array
 and then sampled can go through here, so `words.split` would do what you want,
 but remember that hashes get turned into an array of _pairs_, so expect this
 weirdness if you ask for it:

```ruby
junk({a: 42, b: 13}) # either [:a, 42] or [:b, 13]
```

### Proc

When all else fails, it's time to haul out the lambdas, amirite? The first
argument ot `junk` can be a proc that yields the desired random value. Let's get
those odd numbers again:

```ruby
junk ->{ rand(5)*2 + 1 } # 1-digit odd number
```

### Other Options

### Exclude

Besides the options that `:int` will take, all of the types will accept an
`exclude` argument. This is useful if you want to generate more than one piece
of junk data and ensure that they are different. The exclude option can be given
a single element, an array, or an enumerable, and if all that fails you can give
it a proc that accepts the generated value and returns true if the value should
be excluded. Let's use all these excludes to generate odd numbers again:

```ruby
junk :int, min: 1, max: 3, exclude: 2 # stupid, but it works
junk (1..9), exclude: [2,4,6,8]
junk (1..9), exclude: (2..8) # okay, only returns 1 or 9 but hey,
                             # they're both odd
junk :int, exclude: ->(x) { x % 2 == 0 } # reject even numbers
```

But again, the real advantage is being able to avoid collisions:

```ruby
let(:id1) { junk (0..9) }
let(:id2) { junk (0..9), exclude: id1 }
let(:id3) { junk (0..9), exclude: [id1, id2] }

let(:coinflip) { junk :bool }
let(:otherside) { junk :bool, exclude: coinflip } # Look I never said
    # all of these were great ideas, I'm just saying you can DO them.
```

*VERY IMPORTANT CAVEAT* If you exclude all of the possibilities from the random
key space, junk will cheerfully go into an infinite loop.

### Format

A format can be applied to junk data after generation. This lets you change the
class or representation of the junk. For example, this feature was added because
we needed 6-digit decimal ids... represented as strings. Originally I wrote

```ruby
let(:drug_id) { junk( ->{ junk(:int, size: 6).to_s } ) }
```

But now I can just say

```ruby
let(:drug_id) { junk(:int, size: 6, format: :string) }
```
Here are the available formats:

* `format: :int` calls `.to_i` on the junk before returning it
* `format: :string` calls `.to_s` on the junk
* `format: "%s"` (or any other string) calls sprintf on the junk with the
  string as the format string
* `format: SomeClass` passes the junk to `SomeClass.new`, returning an instance
  of `SomeClass`. *Important:* This class must implement a `#format` method
  which returns the formatted junk. See the `::Junklet::Formatter` class for an
  example class that simply returns the unmodified junk.
* `format: ->(x) { ... }` passes the junk to your Proc; whatever you return is
  the value of the junk. This is obviously the most powerful transform as it can
  return anything at all; there's nothing stopping you from using the format
  proc as the generator itself aside from the constraints of good taste. ;-) If
  you _were_ to exhibit poor taste, one conceivable (yet still very strained)
  example might be `junk :int, format: ->(x) { srand(x); rand }` but it's not
  really a very far stretch to generate, say, a random index in the generator
  and use the formatter to map it to a dictionary word or some other very wild
  transformation.

### Formatter Classes

The careful reader will have noted by now that you can pass a class name as a
format. This is intended to be a Formatter class. A Formatter class takes the
generated junk in its initialize method. If the class implements `#format`, this
method will be called and the return value of this method will be the junk
data. If the class does not implement `#format`, the Formatter object itself
will be returned and you can use it how you see fit. It's probably a good idea
to implement `#to_s` if your formatter is going to wind up in a string
somewhere.

So for example, let's say you want to generate a ZIP+4 code. That's a 5-digit
decimal number, a hyphen, and a 4-digit decimal. This whole mess is then
represented as a string. You could do this with a simple lambda:

```ruby
let(:zip) { junk :int, size: 9, format: ->(x) { '%d-%d' % [x/10000, x%10000] } }
```

...but if you're going to be generating ZIP codes regularly, a formatter class
is probably in order:

```ruby
class Format::ZipCode
  attr_reader :code
  def initialize(code)
    @code = code
  end

  def format
    '%d-%d' % [x/10000, x%10000]
  end
end
```

Now your junk uses the class as designed:

```ruby
let(:zip) { junk :int, size: 9, format: Format::ZipCode }
```

TODO: Hrm, if I'm going to do to that much trouble, why not have an entire junk
generation class? E.g. include the generator with the formatter, so that we can
just say

```ruby
let(:zip) { junk ZipCode }
```

# TODO

* Allow all args to junk to be passed to junklet. Use explicit `type` option to
  specify the type. E.g. `junklet :foo, :bar, :baz, type: :int, max: 14,
  exclude: [:qaz, :qux]`. _(Do we want to allow a flag for mutually exclusive?)_

# Background

At CoverMyMeds we have a legacy impingement that prevents us sometimes from
clearing out data from previous test runs. As a result we often have required
fields in tests that must be unique but are tested elsewhere, so we don't really
care about them in the current test run. For the current test we just want to
stub out that field with something unique but we also want to communicate to the
developer that the contents of the field are not what we currently care about.

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

...etc. Later in the spec we'll often test against those stubs, e.g. with
`expect(user.first_name).to eq(first_name)` but this idiom expresses that we
only care about the equality, not the actual contents.

Junklet seeks to improve the readability and conciseness of this intention. One
thing that bugs me about the above approach is that if a weird regression bug
appears and an unimportant field is the source of a crash. So with Junklet I
also wanted to add the ability to call out the offending field by name. In
theory we could just write `let(:first_name) { 'first_name-' + SecureRandom.uuid
}` but in practice that creates duplication in the code and muddies the original
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

This will have the same effect as calling `let` on the named fields and setting
the fieldname and a 32-byte hex string (a uuid with hyphens removed) to be the
memoized value.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/junklet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Write specs to document how your change is to be used
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
