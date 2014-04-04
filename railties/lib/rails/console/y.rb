unless Kernel.private_method_defined?(:y)
  begin
    require "psych/y"
  rescue LoadError
    module Kernel
      def y(*objects)
        puts Psych.dump_stream(*objects)
      end
      private :y
    end
  end
end
