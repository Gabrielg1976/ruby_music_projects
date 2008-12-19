require 'rubygems'
require 'midilib'
require 'main_midi_logic'
require 'scales_mod'

def to_midi_note(n)
  return 0 if n == 'c'
  return 1 if n == 'C'
  return 2 if n == 'd'
  return 3 if n == 'D'
  return 4 if n == 'e'
  return 5 if n == 'f'
  return 6 if n == 'F'
  return 7 if n == 'g'
  return 8 if n == 'G'
  return 9 if n == 'a'
  return 10 if n == 'A'
  return 11 if n == 'b'
end
  

duration=["quarter","half","whole"]# ,"8th","16th","32nd","64th"]
bpm = ARGV[0].to_i
song = MIDI::Sequence.new

song.tracks << (melody = TimedTrack.new(0,song))

melody.instrument = 29 ;  

melody.events << MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(bpm)) # Controls tempo 
melody.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME,'Alphacore') # title of track

notes = ARGV[1]
seq = notes.split('.')
seq.each do |note|
  melody.add_notes(to_midi_note(note[0,1]), 127, duration[note.length - 1].to_s)
end

open(ARGV[2], 'w') { |f| song.write(f) }

