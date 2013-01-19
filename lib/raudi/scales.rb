module Raudi
  class Note
    # Add some methods to the note class :O
    def major_scale
      DiatonicScale.new(self, :ionian)
    end
  end

  # A diatonic scale :O
  class DiatonicScale < Array
    Degrees = %w(tonic supertonic mediant subdominant dominant submediant leading_tone octave).map(&:to_sym)
    Modes = %w(ionian dorian phyrgian lydian aeolian locrian).map(&:to_sym)
    Pattern = %w(2 2 1 2 2 2 1).map(&:to_i)

    def initialize(key, mode)
      @key = key
      @mode = mode

      # Define degrees...
      pat = Pattern.rotate(Modes.index(mode))
      semitones = 0
      Degrees.each_with_index do |name, i|
        idx = Degrees.index(name)
        self << @key.transpose(pat.take(idx).inject(:+) || 0)
        semitones += pat[i] unless i >= pat.length
      end
    end

    Modes.each do |name|
      define_method name do
        DiatonicScale.new(@key, name)
      end
    end

    Degrees.each_with_index do |name, i|
      define_method name do
        self[i]
      end
    end
  end
end