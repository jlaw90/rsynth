module RSynth
  class Oscillator
    PI2 = Math::PI*2
    TableLength = 1024
    SinTable = TableLength.times.map{|i| Math.sin((PI2 * i) / TableLength)}
    CosTable = TableLength.times.map{|i| Math.cos((PI2 * i) / TableLength)}

    include RSynth::Functions

    attr_accessor :freq, :func

    def initialize(func, freq)
      @freq = freq
      @func = func
      @phase = 0
    end

    def value_at(time)
      f = @freq.value_at(time)
      i = @phase
      @phase = (@phase + (f.to_f / RSynth::SampleRate)) % 1.0
      case @func
        when :sin, :sine then SinTable[(i*TableLength).to_i]
        when :cos, :cosine then CosTable[(i*TableLength).to_i]
        when :sq, :square then i <= 0.5? 1: -1
        when :tri, :triangle then i <= 0.25? (i * 4): i <= 0.5? (1 - (i - 0.25) * 4): i <= 0.75? (0 - (i - 0.5) * 4): (i - 0.75) * 4 - 1
        when :saw, :sawtooth then i * 2 - 1
        else @func.value_at(@phase)
      end
    end
  end
end