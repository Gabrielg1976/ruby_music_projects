require 'midilib'
class Array
  
  def to_midi(file, note_length="8th") 
    midi_max = 128.0
    midi_min = 0.0
    low, high = min, max
    
    song = MIDI::Sequence.new
    
    song.tracks << (melody = MIDI::Track.new(song))
    melody.events << MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(120))
    
    melody.events << MIDI::ProgramChange.new(0, 34)
      
      each do |number|
       midi_note = (midi_min + ((number-midi_min) * (midi_max-low)/high)).to_i
       melody.events << MIDI::NoteOnEvent.new(0, midi_note, 127, 0)
       melody.events << MIDI::NoteOffEvent.new(0, midi_note, 127,
       song.note_to_delta(note_length))
      end
       open(file, 'w') { |f| song.write(f) }
  end
end