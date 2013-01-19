module RSynth
  class Note
    ChromaticInterval = 2**(1.0/12)
    ChromaticNotes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    IntervalMap = [
        %w(perfect_unison unison P1 diminished_second d2),
        %w(minor_second m2 augmented_unison A1 semitone S),
        %w(major_second M2 diminished_third d3 tone whole_tone T),
        %w(minor_third m3 augmented_second A2),
        %w(major_third M3 diminished_fourth d4),
        %w(perfect_fourth fourth P4 augmented_third A3),
        %w(tritone diminished_fifth d5 augmented_fourth A4 TT),
        %w(perfect_fifth fifth P5 diminished_sixth d6),
        %w(minor_sixth m6 augmented_fifth A5),
        %w(major_sixth M6 diminished_seventh d7),
        %w(minor_seventh m7 augmented_sixth A6),
        %w(major_seventh M7 diminished_octave d8),
        %w(perfect_octave octave P8 augmented_seventh A7)
    ]
    include RSynth::Functions

    attr_reader :note, :octave, :freq

    def initialize(note, octave)
      @note = note.upcase
      @octave = octave
      raise "Invalid note value: #{note}" unless ChromaticNotes.include?(@note)
      raise "Invalid octave: #{octave}, must be >= 0" if octave < 0

      # Calculate frequency (notes are relative to A4 (440Hz))
      rn = -(ChromaticNotes.index('A') - ChromaticNotes.index(@note))
      ro = @octave - 4
      steps = (ro * 12) + rn
      @freq = 440*(ChromaticInterval**steps)
    end

    def value_at(time)
      @freq
    end

    def next
      transpose(1)
    end

    def previous
      transpose(-1)
    end

    def previous_octave
      transpose(-12)
    end

    def transpose(count=1)
      oct = @octave
      ni = ChromaticNotes.index(@note)
      ni += count
      while ni >= ChromaticNotes.length
        oct += 1
        ni -= ChromaticNotes.length
      end
      while ni < 0
        oct -= 1
        ni += ChromaticNotes.length
      end
      Note.retrieve(ChromaticNotes[ni], oct)
    end

    def to_s
      "#@note#@octave"
    end

    def <=>(note)
      os = @octave <=> note.octave
      return os unless os == 0
      ChromaticNotes.index(@note) <=> ChromaticNotes.index(note.note)
    end

    def self.retrieve(note, octave)
      note.upcase!
      name = "#{note.sub('#', 'Sharp')}#{octave}"
      RSynth.const_set(name, Note.new(note, octave)) unless RSynth.const_defined?(name)
      RSynth.const_get(name)
    end

    # Define the interval methods...
    IntervalMap.each_with_index do |names, interval|
      names.each do |name|
        define_method(name.to_sym) do
          self.transpose(interval)
        end
      end
    end
  end

  # Define the chromatic scale at octaves 0-9
  9.times do |o|
    Note::ChromaticNotes.each do |n|
      Note.retrieve(n, o)
    end
  end
end