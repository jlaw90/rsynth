module Raudi
  module Functions
    def combine(type, other)
      case type
        when :add, :plus
          Raudi::Combiner.new(self, other) { |a, b| a + b }
        when :sub, :subtract, :minus
          Raudi::Combiner.new(self, other) { |a, b| a - b }
        when :div, :divide
          Raudi::Combiner.new(self, other) { |a, b| a / b }
        when :mul, :multiply, :times
          Raudi::Combiner.new(self, other) { |a, b| a * b }
        when :exp, :exponent, :pow, :power
          Raudi::Combiner.new(self, other) { |a, b| a ** b }
        when :mod, :modulo, :rem, :remainder
          Raudi::Combiner.new(self, other) { |a, b| a % b }
        when :mix
          Raudi::Combiner.new(self, other) do |a, b|
            # Normalise between 0 and 1
            a = (a + 1) / 2
            b = (b + 1) / 2
            z = (a < 0.5 and b < 0.5)? 2*a*b : 2*(a+b) - (2*a*b) - 1
            # Convert back
            (z * 2) - 1
          end
        else
          raise "Unknown combiner type: #{type}"
      end
    end

    def phase_shift(offset=nil)
      offset = Proc.new{ |time| yield time } if block_given?
      raise 'No offset or block given' if offset.nil?
      Raudi::PhaseShifer.new(self, offset)
    end

    # won't work for numeric or proc (unless we override but there'd be a huge performance hit)
    def +(other)
      combine(:add, other)
    end

    def -(other)
      combine(:sub, other)
    end

    def /(other)
      combine(:div, other)
    end

    def *(other)
      combine(:mul, other)
    end

    def **(other)
      combine(:exp, other)
    end

    def %(other)
      combine(:mod, other)
    end

    def &(other)
      combine(:mix, other)
    end

    def <<(offset)
      phase_shift(-offset)
    end

    def >>(offset)
      phase_shift(offset)
    end
  end
end

class Proc
  include Raudi::Functions

  def value_at(time)
    self.call(time)
  end
end

# Add mixins to int and float :O
class Numeric
  include Raudi::Functions

  def value_at(time)
    self
  end
end