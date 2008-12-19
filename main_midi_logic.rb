require 'rubygems'
require 'midilib'
require 'scales'


class TimedTrack < MIDI::Track
MIDDLE_C = 60
@@channel_counter=0

def initialize(number, song)
super(number)
@sequence = song
@time = 0
@channel = @@channel_counter
@@channel_counter += 1
end

def instrument=(instrument)
@events <<  
MIDI::ProgramChange.new(@channel, instrument)
super(MIDI::GM_PATCH_NAMES[instrument])
end

def add_notes(offsets, velocity=127, duration='quarter')
offsets = [offsets] unless offsets.respond_to? :each
offsets.each do |offset|
  event(MIDI::NoteOnEvent.new(@channel, MIDDLE_C + offset, velocity))
end
@time += @sequence.note_to_delta(duration)
offsets.each do |offset|
  event(MIDI::NoteOffEvent.new(@channel, MIDDLE_C + offset, velocity))
end
recalc_delta_from_times
end

# Uses add_notes to sound a chord
# Working on a chord Progression 

def chord_maj1(low_note, velocity=127, duration='quarter')
add_notes([0,4,7].collect { |x| x + low_note }, velocity, duration)
end

def chord_min2(low_note, velocity=127, duration='quarter')
add_notes([2,5,9].collect { |x| x + low_note }, velocity, duration)
end

def chord_min3(low_note, velocity=127, duration='quarter')
add_notes([4,7,11].collect { |x| x + low_note }, velocity, duration)
end

def chord_maj4(low_note, velocity=127, duration='quarter')
add_notes([5,9,0].collect { |x| x + low_note }, velocity, duration)
end

def chord_maj5(low_note, velocity=127, duration='quarter')
add_notes([7,11,2].collect { |x| x + low_note }, velocity, duration)
end

def chord_min6(low_note, velocity=127, duration='quarter')
add_notes([9,0,4].collect { |x| x + low_note }, velocity, duration)
end

def chord_min7(low_note, velocity=127, duration='quarter')
add_notes([11,2,5].collect { |x| x + low_note }, velocity, duration)
end

# ::::::::::::::::::::::::::::::::::::
# This set of chords are all set in C and are the Main Popular Chords
# ::::::::::::::::::::::::::::::::::::

def chord_maj(low_note, velocity=127, duration='quarter')
add_notes([0,4,7].collect { |x| x + low_note }, velocity, duration)
end

def chord_maj7th(low_note, velocity=127, duration='quarter')
add_notes([0,4,7,10].collect { |x| x + low_note }, velocity, duration)
end

def chord_maj_7th(low_note, velocity=127, duration='quarter')
add_notes([0,4,7,11].collect { |x| x + low_note }, velocity, duration)
end

def chord_maj9th(low_note, velocity=127, duration='quarter')
add_notes([0,4,7,10,2].collect { |x| x + low_note }, velocity, duration)
end

def chord_maj_aug(low_note, velocity=127, duration='quarter')
add_notes([0,4,8].collect { |x| x + low_note }, velocity, duration)
end

def chord_min(low_note, velocity=127, duration='quarter')
add_notes([0,3,7].collect { |x| x + low_note }, velocity, duration)
end

def chord_min_aug(low_note, velocity=127, duration='quarter')
add_notes([0,3,8].collect { |x| x + low_note }, velocity, duration)
end

def chord_min7th(low_note, velocity=127, duration='quarter')
add_notes([0,3,7,10].collect { |x| x + low_note }, velocity, duration)
end

def chord_min_7th(low_note, velocity=127, duration='quarter')
add_notes([0,3,7,11].collect { |x| x + low_note }, velocity, duration)
end

def chord_min9th(low_note, velocity=127, duration='quarter')
add_notes([0,3,7,10,2].collect { |x| x + low_note }, velocity, duration)
end

private
def event(event)
@events << event
event.time_from_start = @time
end
end
