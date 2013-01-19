module RSynth
  class PhaseShifter
    include RSynth::Functions
    attr_accessor :source, :offset

    def initialize(source, offset=nil)
      offset = Proc.new {|time| yield time} if block_given?
      raise 'No offset or block defined' if offset.nil?
      @source = source
      @offset = offset
    end

    def value_at(time)
      @source.value_at(time + @offset.value_at(time))
    end
  end
end