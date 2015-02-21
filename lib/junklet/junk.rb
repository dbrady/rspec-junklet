module Junklet
  module Junk
    def junk(*args)
      # TODO: It's long past time to extract this....

      # args.first can be
      # - an integer indicating the size of the hex string to return
      # - a symbol denoting the base type, e.g. :int
      # - an array to sample from
      # - a range or Enumerable to sample from. WARNING: will call
      #   .to_a on it first, which might be expensive
      # - a generator Proc which, when called, will generate the
      #   value to use.
      #
      # args.rest is a hash of options:
      # - sequence: Proc or Array of values to choose from.
      # - exclude: value, array of values, or proc to exclude. If a
      #   Proc is given, it takes the value generated and returns
      #   true if the value should be excluded.
      #
      # - for int:
      #   - min: minimum number to return. Default: 0
      #   - max: upper limit of range
      #   - exclude: number, array of numbers, or proc to
      #     exclude. If Proc is provided, tests the number against
      #     the Proc an excludes it if the Proc returns true. This
      #     is implemented except for the proc.

      # FIXME: Would be nice to be able to say, e.g. `junk exclude: bob` but
      #        currently this breaks because {exclude: bob} is a Hash which is
      #        an Enumerable which means it's a valid generator. I don't want to
      #        just disallow hashes as generators here. What's a good workaround
      #        for when I really do just want junk with either a format or an
      #        exclusion? `junk :junk, exclude: bob` looks bad. `junk _,
      #        exclude: bob` is also pretty bad.
      #
      #        Hmm, I'm tempted to say "the one enumerable you CAN'T have is a
      #        Hash, so it can be the options hash; if you DO want to pass in a
      #        hash, you must cast it to an array or yield it from a Proc
      #        instead". Given that the hash case is weird and rare enough, I
      #        think this is acceptable. Oh, if only I didn't have to maintain
      #        backwards compatibility with older Rubies, I could just make
      #        these keyword args. Sigh.

      # FIXME: This whole darn method is outta control, and for the record none
      #        of the cool excluders and formatters work with the
      #        SecureRandom.hex default. Barf.

      # FIXME: Raise Argument error unless *args.size is 0-2
      # FIXME: If arg 1 is a hash, it's the options hash, raise
      #        ArgumentError unless args.size == 1
      # FIXME: If arg 2 present, Raise Argument error unless it's a
      #        hash.
      # FIXME: Figure out what our valid options are and parse them;
      #        raise errors if present.

      junk_types = [Symbol, Array, Enumerable, Proc]
      if args.size > 0 && junk_types.any? {|klass| args.first.is_a?(klass) }
        type = args.shift
        opts = args.last || {}

        excluder = if opts[:exclude]
                     if opts[:exclude].is_a?(Proc)
                       opts[:exclude]
                     else
                       ->(x) { Array(opts[:exclude]).include?(x) }
                     end
                   else
                     ->(x) { false }
                   end

        formatter = case opts[:format]
                    when :string
                      ->(x) { x.to_s }
                    when :int
                      ->(x) { x.to_i }
                    when String
                      ->(x) { sprintf(opts[:format], x) }
                    when Class
                      ->(x) { opts[:format].new(x) }
                    when Proc
                      opts[:format]
                    else
                      ->(x) { x }
                    end

        # TODO: Refactor me. Seriously, this is a functional
        # programming version of the strategy pattern. Wouldn't it
        # be neat if we had some kind of object-oriented language
        # available here?
        case type
        when :int
          # min,max cooperate with size to further constrain it. So
          # size: 2, min: 30 would be min 30, max 99.
          if opts[:size]
            sized_min = 10**(opts[:size]-1)
            sized_max = 10**opts[:size]-1
          end
          explicit_min = opts[:min] || 0
          explicit_max = (opts[:max] || 2**62-2) + 1

          if sized_min
            min = [sized_min, explicit_min].max
            max = [sized_max, explicit_max].min
          else
            min = sized_min || explicit_min
            max = sized_max || explicit_max
          end

          min,max = max,min if min>max

          generator = -> { rand(max-min) + min }
        when :bool
          generator = -> { [true, false].sample }
        when Array, Enumerable
          generator = -> { type.to_a.sample }
        when Proc
          generator = type
        else
          raise "Unrecognized junk type: '#{type}'"
        end

        begin
          val = formatter.call(generator.call)
        end while excluder.call(val)
        val
      else
        size = args.first.is_a?(Numeric) ? args.first : 32
        # hex returns size*2 digits, because it returns a 0..255 byte
        # as a hex pair. But when we want junt, we want *bytes* of
        # junk. Get (size+1)/2 chars, which will be correct for even
        # sizes and 1 char too many for odds, so trim off with
        # [0...size] (note three .'s to trim off final char)
        SecureRandom.hex((size+1)/2)[0...size]
      end
    end
  end
end
