require 'ffi-portaudio'

module RSynth
  module Pipe
    class PortAudio
      include ::FFI::PortAudio

      def initialize
        wrap_call('initialise portaudio') { | | API.Pa_Initialize() }
        @buf = FFI::Buffer.new(:float, RSynth::Pipe::Pipeline::FramesPerBuffer, true) # Create our native buffer
      end

      def start(pipeline)
        @source = pipeline
        open_stream
      end

      def stop
        close_stream
        @source = nil
      end

      private
      def process input, output, frame_count, time_info, status_flags, user_data
        n = @source.consume(self)
        return :pcComplete if n.nil?
        output.write_array_of_float(n)
        @source.consumed(self)
        :paContinue
      end

      def open_stream
        close_stream unless @stream.nil?
        # Get the audio host
        info = wrap_call('get default audio host') do | |
          return idx if error?(idx = API.Pa_GetDefaultHostApi())
          API.Pa_GetHostApiInfo(idx)
        end

        # Get the default device
        inIdx = info[:defaultInputDevice] # Todo: add sampling for luls
        outIdx = info[:defaultOutputDevice]
        outDev = wrap_call 'get device info' do | |
          API.Pa_GetDeviceInfo(outIdx)
        end

        # Create parameters for the output stream
        outopts = API::PaStreamParameters.new
        outopts[:device] = outIdx
        outopts[:channelCount] = RSynth::Channels
        outopts[:sampleFormat] = API::Float32
        outopts[:suggestedLatency] = outDev[:defaultHighOutputLatency]
        outopts[:hostApiSpecificStreamInfo] = nil

        @stream = FFI::Buffer.new :pointer
        @callback = method(:process)
        wrap_call('open output stream') do | |
          API.Pa_OpenStream(
              @stream, # Stream
              nil, # Input options
              outopts, # Output options
              RSynth::SampleRate, # the sample rate
              RSynth::Pipe::Pipeline::FramesPerBuffer, # frames per buffer
              API::PrimeOutputBuffersUsingStreamCallback, # flags
              @callback, # Callback
              nil # User data
          )
        end

        # Start the stream playing
        wrap_call('starting output stream') do | |
          API.Pa_StartStream @stream.read_pointer
        end
      end

      def close_stream
        return if @stream.nil?
        API.Pa_CloseStream(@stream.read_pointer)
        @stream = nil
      end

      def error?(val)
        (Symbol === val and val != :paNoError) or (Integer === val and val < 0)
      end

      def wrap_call(msg, &block)
        ret = yield block
        raise "Failed to #{msg}: #{API.Pa_GetErrorText(ret)}" if error?(ret)
        return ret
      end
    end
  end
end