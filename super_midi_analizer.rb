# Get all measures, so events can be mapped to measures:
require 'rubygems'
require 'midilib'
require 'midilib/sequence'
require 'rubymusicengine'
require 'scales'

def song_creator_and_display
 seq = MIDI::Sequence.new()
  s=[ ]
 100.times {|n| s << lydian_min[rand(lydian_min.size)] }
 s.to_midi("new_song.mid")
# Then takes the new generated midi file and maps out the notes and time 
 File.open("new_song.mid", 'rb') { | file | seq.read(file) }
 measures = seq.get_measures 
 count=0  
  seq.each { | track |
  track.each { | e |
   if e.note_on? then
    count = count + 1
    e.print_note_names = true
    # puts "the note #{count} was #{e.note_to_s}"
    puts measures.to_mbt(e)+ " " + "#{e.note_to_s}"
    end
   }
 }
end

song_creator_and_display