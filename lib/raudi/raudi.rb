require_relative 'pipe/pipeline'
require_relative 'pipe/portaudio'
require_relative 'functions'
require_relative 'combiner'
require_relative 'phase_shifter'
require_relative 'oscillator'
require_relative 'notes'
require_relative 'scales'

module Raudi
  SampleRate = 22050
  TimeStep = 1.0/SampleRate
  Channels = 1
end