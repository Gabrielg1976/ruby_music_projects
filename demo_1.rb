require 'music'
require 'scales'
count=0

number_notes=8

midi = LiveMIDI.new 

until count > number_notes 

# Channel / Note / Velocity
puts "note" + " "+"#{count+=1}"

midi.note_on(ch=rand(8),note=harmonic_minor[rand(harmonic_minor.length)],vlc=rand(75)+25)

sleep(1)# = 1 second of time 60 = minute

midi.note_off(ch,note,0)

end

puts "Song Over"