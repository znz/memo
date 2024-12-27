require 'delegate'
require 'pathname'

class Delegator
  ruby2_keywords def method_missing(m, *args, &block)
    r = true
    target = self.__getobj__ {r = false}

    if r && target_respond_to?(target, m, false)
      Object.__send__(:pp, target:, m:, args:, block:)
      Object.__send__(:p, target.__send__(m, *args, &block))
    elsif ::Kernel.method_defined?(m) || ::Kernel.private_method_defined?(m)
      ::Kernel.instance_method(m).bind_call(self, *args, &block)
    else
      super(m, *args, &block)
    end
  end
end

MyClass = DelegateClass(Pathname) do
  def initialize(path)
    super(Pathname.new(path))
  end

  def to_s
    'to_s'
  end

  def to_str
    'to_str'
  end

  def to_path
    p :to_path
    super
  end
end

# p File.join(MyClass.new("foo"), MyClass.new("bar"))
p File.join(SimpleDelegator.new("foo"), SimpleDelegator.new("bar"))
p File.join(SimpleDelegator.new(Pathname("foo")), SimpleDelegator.new(Pathname("bar")))

puts 'String.try_convert'
p String.try_convert(SimpleDelegator.new(MyClass.new("foo")))
p String.try_convert(SimpleDelegator.new(Pathname("foo")))
