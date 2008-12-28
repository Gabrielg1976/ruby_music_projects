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



def test_drive_progression(midi_object,root_note,scale,chord,progression,duration = 1)
  chan=rand(8)
  chords = progression.map{|deg|
    root_note.send(scale).harmonized_chord(deg,chord)
  }    
  chords.each{|chord|
    play_chord(midi_object,chord,chan,duration,rand(75)+25)
  }
end

midi = LiveMIDI.new 
 
intro = [1,4,5,8]
part_a = [8,4,8,4,9,7,2,5]
part_b = [1,3,6,9,5,7,2,5]
ending = [8,4,1,7,8]
prog = intro + part_a + part_a + part_b + part_a + ending

puts "play the progression with a major_chord"
test_drive_progression(midi,Note.new("C"), :major_scale, :major_chord,prog,1)
sleep(1)
puts "and now again, with maj7_chord"
test_drive_progression(midi,Note.new("C"), :major_scale, :maj7_chord,prog,1)

puts "The Composition is Finished"
