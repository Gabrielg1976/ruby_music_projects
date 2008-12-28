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


def test_drive(midi_object,root_note,scale,chord,duration = 1)
  chan=rand(8)
  chords = root_note.send(scale).all_harmonized_chords(chord)
  
  last_chord = chords.first
  #hacky
  last_chord = last_chord.invert
  while last_chord.notes.first.name != last_chord.root_note.name
    last_chord = last_chord.invert
  end
  
  chords.each{|chord|
    play_chord(midi_object,chord,chan,duration,rand(75)+25)
  }
  #and finish on the last_chord
  play_chord(midi_object,last_chord,duration,chan,rand(75)+25)

  #FIXME: not sure why the last_chord seems to sustain for a longer time
end

midi = LiveMIDI.new 
 
test_drive(midi,Note.new("C"), :major_scale, :maj7_chord,0.2)
test_drive(midi,Note.new("C"), :phrygian_scale, :min7_chord,0.2)

puts "The Composition is Finished"
