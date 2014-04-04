unless Kernel.private_method_defined?(:y)
  if RUBY_VERSION >= '2.0'
    require "psych/y"
  else
    module Kernel
      def y(*objects)
        puts Psych.dump_stream(*objects)
      end
      private :y
    end
  end
end
