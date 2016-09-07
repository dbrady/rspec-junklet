module RSpec
  module Junklet
    module Junklet
      def junklet(*args)
        # TODO: figure out how to use this to wrap junk in junklet,
        # so that junklet can basically have all the same options as
        # junk does. E.g. junklet :ddid, :pcn, :group, type: :int,
        # min: 100000, max: 999999, etc, and you'd get back 3
        # junklets of 6-digit numbers.
        opts = args.size > 1 && !args.last.is_a?(Symbol) && args.pop || {}

        names = args.map(&:to_s)

        separator = opts[:separator] || '_'
        names = names.map {|name| name.gsub(/_/, separator)}

        args.zip(names).each do |arg, name|
          make_junklet arg, name, separator
        end
      end

      def make_junklet(let_name, name, separator)
        let(let_name) { "#{name}#{separator}#{junk}" }
      end
    end
  end
end
