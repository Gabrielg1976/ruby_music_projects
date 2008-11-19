# This is the Start of A Generating Music and Midi files using Ruby code plan on building
# more features like better chord system user controls please feel to add features that you think 
# should be added.. to  feature to do list 

# DON'T FORGET YOU MUST HAVE THE MIDILIB GEM INSTALLED   gem install midilib  

# Features to do List 
#     
#     let user choose number of melody tracks to generate
#     let user choose number of chord tracks to generate
#     build a Better way of calling scales and chords ( instead of hardcoding them )
     

require 'rubygems'
require 'midilib'
require 'main_midi_logic'
require 'scales_mod'

duration=["whole","half","quarter"]# ,"8th","16th","32nd","64th"]

count =-1

puts"Please title this composition"
title=gets.chomp!

puts "Please enter the bpm you like"
bpm=gets.to_i

puts "how compositions would you like to generate with these specs ?"
num=gets.to_i


num.times { count += 1
song = MIDI::Sequence.new

# Currently generates 1 melody and 1 chord but cn easily add more 

song.tracks << (melody = TimedTrack.new(0,song))
song.tracks << (chords = TimedTrack.new(1, song))

melody.instrument = 0 ; chords.instrument = 5 # Setting the instruments 

melody.events << MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(bpm)) # Controls tempo 
melody.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME,'Alphacore') # title of track

note = 0

# can be changed or could be created by user input in the future
(10*10).times do |i|

# Calls a scale method from the scale_mod.rb file check it out for more info
note += locrian_natural[rand(locrian_natural.length)]-60

note = 0 if note < -39 or note > 48

melody.add_notes(note, 127, duration[rand(duration.size)].to_s)
# Add a chord of whole notes at the beginning of each measure.
chords.chord_maj5(note, 75,duration[rand(duration.size)].to_s)

end

open( title +"#{count}"+".mid", 'w') { |f| song.write(f) }
}