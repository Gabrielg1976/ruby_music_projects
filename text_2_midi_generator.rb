# Created using the Midi Library Gem created by Jim Menerad
# to_midi Provided from the Rails Cookbook 
# This script generates plain text into a single midi Track 
#  All Converion and Application logic Created & Designed by Gabriel G. Updated Aug 24th 2008
#  char "alphabet" Ascii range is 65-122 (not including 91-96) lowercase 97-122 uppercase 65-90
# 
# Added Features 
# Menu with converting options Read as Followed 
# 1 => User input of text 
# 2 => Read in a text file
# 3 => User Choose a number of random letters to be generated
require 'rubygems'
require 'midilib'

class Array
    
     def to_midi(file, note_length='half')
        midi_max = 128.0
        midi_min = 0.0
        low, high = min, max
        
        song = MIDI::Sequence.new
       
        song.tracks << (melody = MIDI::Track.new(song))
       
        melody.events <<  
       
        MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(120))
        melody.events << MIDI::ProgramChange.new(0, 0)
       
        each do |number|
         midi_note = (midi_min + ((number-midi_min) * (midi_max-low)/high)).to_i
         melody.events << MIDI::NoteOnEvent.new(0, midi_note, 127, 0)
         melody.events << MIDI::NoteOffEvent.new(0, midi_note, 127,
         song.note_to_delta(note_length))
        end
        open(file, 'w') { |f| song.write(f) }
      end
    end
    
    
    
    
    # Main Menu of a standalone Text_2_midi Converter 
    puts "Text_2_Midi Converter "
    puts "1 = User input"
    puts "2 = reads in for a text file"
    puts "3 = generates set random letter pattern based user"
    puts "Please choose a Number between 1-3"
    
    
    option = gets.chomp
    case option

   when "1"
    # WORKS allows you to Name the Track and Input Text 
    puts "Please enter the title of this track"
    title=gets.upcase.chomp
    puts
    puts "Please Enter some Text \t(Press Enter)"
    text=gets.upcase.chomp
    puts
    text_array = [ ] 
    text.each_byte {|c| text_array << c-5}  
    puts
    p text_array
    text_array.to_midi("#{title}.mid")
   when "2"
       # WORKS Converts a Requested txt File into Midi 
    midi_me_array=[]
    puts "Please enter the title of this track"
    title=gets.upcase.chomp
    puts
    puts"Please enter the text file name you are looking for"
    text =gets.downcase.chomp!
    IO.foreach("#{text}"){|line| p line} 
    IO.foreach("#{text}")do |line| 
    text.each_byte {|c| midi_me_array << c-5}  
    end
    midi_me_array.to_midi("#{title}.mid")
   when "3"
    # WORKS
    chars = ("a".."z").to_a 
    pattern_array =[] 
    puts "Please enter the title of this track"
    title=gets.upcase.chomp
    puts 
    puts"Please enter the number of letters you like in your pattern (Press Enter)"
    textnum=gets.to_i
    pattern = Array.new(textnum, '').collect{chars[rand(chars.size)]}.join
    pattern.upcase.each_byte {|c| pattern_array << c-5} 
    pattern_array.to_midi("#{title}.mid") 
    puts pattern_array
    end
