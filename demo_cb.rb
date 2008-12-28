require 'music'
require 'scales'
require 'rubygems'
require 'cb-music-theory'

def play_chord(midi_object,chord,channel,duration,velocity)
  chord.note_values.each{|note|
    midi_object.note_on(channel,note,velocity)
  }
  #sustain it a bit
  sleep(duration)
  #release the chord
  chord.note_values.each{|note|
    midi_object.note_off(channel,note,0)
  }
end

midi = LiveMIDI.new 
 
chan=rand(8)

chords = Note.new("C").major_scale.all_harmonized_chords(:maj7_chord)

#inverted until it's an octave up
last_chord = chords.first.invert.invert.invert.invert

chords.each{|chord|
  play_chord(midi,chord,chan,1,rand(75)+25)
}
#and finish on the last_chord
play_chord(midi,last_chord,1,chan,rand(75)+25)

puts "The Composition is Finished"
