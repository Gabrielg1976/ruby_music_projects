require 'music'
require 'scales'
require 'rubygems'
require 'cb-music-theory'


midi = LiveMIDI.new 
 
#a,b,d,e=rand(52)+33,rand(52)+33,rand(52)+33,rand(52)+33

  # Channel / Note / Velocity
#  puts "note" + " "+"#{count+=1}"

#Note.new("C").major_chord.note_values.each{|note|
#  midi.note_on(ch=rand(8),note,vlc=rand(75)+25)
#  sleep(1)# = 1 second of time 60 = minute
#  midi.note_off(ch,note,0)
#}

ch=rand(8)

chords = Note.new("C").major_scale.all_harmonized_chords(:maj7_chord)

#inverted until it's an octave up
last_chord = chords.first.invert.invert.invert.invert

chords.each{|c|
  #play the chord
  c.note_values.each{|note|
    midi.note_on(ch,note,vlc=rand(75)+25)
  }
  #sustain it a bit
  sleep(1)

  #release the chord
  c.note_values.each{|note|
    midi.note_off(ch,note,0)
  }
}

#and finish on the last_chord
last_chord.note_values.each{|note|
  midi.note_on(ch,note,vlc=rand(75)+25)
}
#sustain it a bit
sleep(1)
#release the chord
last_chord.note_values.each{|note|
  midi.note_off(ch,note,0)
}

puts "The Composition is Finished"
