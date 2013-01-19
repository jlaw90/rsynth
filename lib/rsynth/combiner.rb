module RSynth
  class Combiner
    include RSynth::Functions
    attr_accessor :a, :b

    def initialize(a, b, proc=nil)
      proc = Proc.new{|a,b| yield a, b} if block_given?
      raise 'No block or proc given' if proc.nil?
      @proc = proc
      @a = a
      @b = b
    end

    def value_at(time)
      @proc.call(@a.value_at(time), @b.value_at(time))
    end
  end
end