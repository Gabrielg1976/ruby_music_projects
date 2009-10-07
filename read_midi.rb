require 'rubygems'
require 'midilib/sequence'
 
# Get all measures, so events can be mapped to measures:

def note_plotter
 seq = MIDI::Sequence.new()
 # Asks the user for midi tarck to read in.. 
 title=gets.chomp!
 
 File.open("#{title}", 'rb') { | file | seq.read(file) }
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
