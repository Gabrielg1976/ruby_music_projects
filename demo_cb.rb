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

def play_arpeggio(midi_object,chord,channel,duration,velocity)
  arpeggio = chord.note_values
  arpeggio = arpeggio - [arpeggio.last] + arpeggio.reverse
  arpeggio.each{|note|
    midi_object.note_on(channel,note,velocity)
    #sustain it a bit
    sleep(duration)
    midi_object.note_off(channel,note,0)
  }
end

def test_drive_chord(midi_object,root_note,scale,chord,progression,duration = 1)
  chan=rand(8)
  chords = progression.map{|deg|
    root_note.send(scale).harmonized_chord(deg,chord)
  }    
  chords.each{|chord|
    play_chord(midi_object,chord,chan,duration,rand(50)+50)
  }
end

def test_drive_arpeggio(midi_object,root_note,scale,chord,progression,duration = 1)
  chan=rand(8)
  chords = progression.map{|deg|
    root_note.send(scale).harmonized_chord(deg,chord)
  }    
  chords.each{|chord|
    play_arpeggio(midi_object,chord,chan,duration,rand(50)+50)
  }
end



midi = LiveMIDI.new 
 
intro = [1,4,5,8]
part_a = [8,4,8,4,9,7,2,5]
part_b = [1,3,6,9,5,7,2,5]
ending = [8,4,1,7,8]
prog = intro + part_a + part_a + part_b + part_a + ending


#prog = [1,2,3,4,5,6,7,8]
#test_drive_chord(midi,Note.new("C"), :major_scale, :maj7_chord, prog, 0.4)
#test_drive_chord(midi,Note.new("C"), :phrygian_scale, :min7_chord, prog, 0.4)
#test_drive_chord(midi,Note.new("C"), :enigmatic_scale, :aug_chord, prog, 0.4)
#test_drive_chord(midi,Note.new("C"), :hangman_scale, :minor_chord, prog, 0.4)
test_drive_arpeggio(midi,Note.new(48), :major_scale, :add2_chord, prog, 0.2)

puts "The Composition is Finished"
