module Raudi
  module Pipe
    class Pipeline
      NumBuffers = 2 # Number of buffers we keep in our ring buffer
      FramesPerBuffer = 512 # How many bytes per buffer (higher is higher latency, obviously...)

      attr_accessor :sequence, :source
      attr_reader :time

      def initialize(source, *sequence)
        source = Proc.new { |time| yield time } if block_given?
        raise 'No source or block given' if source.nil?
        @sequence = sequence || []
        @source = source
        @stopped = true
      end

      def start(time=Float::INFINITY)
        return unless @stopped
        @stopped = false
        @length = time
        Thread.new {generate}
      end

      def stop
        @stopped = true
      end

      def restart
        stop
        start
      end

      def consume(sequence)
        sidx = @sequence.index(sequence) || @sequence.length
        bidx = @seqpos[sidx] || 0
        @generated[bidx]
      end

      def consumed(sequence)
        sidx = @sequence.index(sequence) || @sequence.length
        bidx = @seqpos[sidx] || 0
        @seqpos[sidx] = bidx + 1 # increment this sequences buffer index entry...

        # If all sequences have consumed the bottom buffer, release it
        if @seqpos.all?{|s| s > 0}
          @buffers.push(@generated.shift)
          @seqpos.map!{|i| i - 1}
          @time += FramesPerBuffer * Raudi::TimeStep
        end
      end

      def generate
        @time = 0
        @generate_time = 0
        timePerLoop = FramesPerBuffer * Raudi::TimeStep
        @buffers = 10.times.map{Array.new(FramesPerBuffer)}
        @generated = []
        @seqpos = @sequence.length.times.map{0}
        @sequence.each { |s| s.start(self) }
        while not @stopped
          if @generate_time < @length
            sleep(Raudi::TimeStep) while (@buffers.length == 0 or @generated.length >= NumBuffers) and not @stopped
            buf = @buffers.shift
            len = @generate_time + timePerLoop > @length ? (@length - @generate_time) / Raudi::TimeStep : FramesPerBuffer
            len.times do |i|
              buf[i] = @source.value_at(@generate_time)
              @generate_time += Raudi::TimeStep
            end
            (FramesPerBuffer - len).times do |i|
              buf[i] = 0
            end
            @generated << buf
          end
        end
        @sequence.each{ |s| s.stop }
      end

      def to_s
        "Raudi::Pipe::Pipeline source=#{@source},seq=#{@sequence}"
      end
    end
  end
end