# Designed by Gabriel  Garrod @ 2009 GNU 
# This project is inspired by John Cage 
# duration is based on time not Musicial Durations such as Quarters and 8th notes  
# Create movements each time it plays through will be considered ( 1 phrase pass of time ) 
# Below are a few examples of movement structures
# two on_midi = 2 part Harmonys & 3 on_midi = Triad Chord 
# movement3 is a 1 min time part played 6 times with 10 seconds of time passing each time

require 'music'
require 'scales'
cnt=0

midi = LiveMIDI.new 

single_channel = Proc.new {
 125.times do 
  puts "note" + " "+"#{cnt+=1}"
  midi.note_on(ch=0,note=lydian_dominant[rand(lydian_dominant.length)],vlc=rand(75)+25)
  sleep(duration[1]) # = 1 second of time 60 = minute
  midi.note_off(ch,note,0)
end 
}


# This is a major Chord
major_chord = Proc.new {
 4.times do
puts "Playing A Major Chord"   
  midi.note_on(ch=0,note8=major[0],vlc=rand(75)+25)
  sleep(1)
  midi.note_on(ch=1,note9=major[2],vlc=rand(75)+25)
  sleep(1)
  midi.note_on(ch=2,note10=major[4],vlc=rand(75)+25)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_off(ch,note8,0)
  midi.note_off(ch,note9,0)
  midi.note_off(ch,note10,0)
  end 
}

# this is the cleanest and dryest way to generate a Dynamic Composition 
randomized_movement = Proc.new {
 7.times do
  midi.note_on(ch=rand(8),note=lydian[rand(lydian.size)],vlc=rand(75)+25)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_off(ch,note,0)
end 
}

two_part_harmonies= Proc.new {
  12.times do
  puts "note" + " "+"#{cnt+=1}"
  puts "This is the Chord number #{cnt+=1}"
   midi.note_on(ch=0,note1=phrygian[rand(phrygian.length)],vlc=rand(75)+25)
   midi.note_on(ch=1,note2=phrygian[rand(phrygian.length)],vlc=rand(75)+25)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_off(ch,note1,0)
  midi.note_off(ch,note2,0)
  end
}

rhythm_01 = Proc.new {
 100.times do 
  puts "note" + " "+"#{cnt+=1}"
  midi.note_on(ch=5,note5=major[rand(major.length)],vlc=100)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_on(ch=6,note6=major[rand(major.length)],vlc=100)
   sleep(1) # = 1 second of time 60 = minute
  midi.note_on(ch=7,note7=major[rand(major.length)],vlc=100)
  midi.note_off(ch,note5,0)
   sleep(1) # = 1 second of time 60 = minute
  midi.note_on(ch=8,note8=major[rand(major.length)],vlc=100)
  midi.note_off(ch,note6,0)
  midi.note_off(ch,note7,0)
  midi.note_off(ch,note8,0)
end 
}

movement1 = Proc.new {
 10.times do
  puts "note" + " "+"#{cnt+=1}"
  midi.note_on(ch=rand(8),note=harmonic_minor[rand(harmonic_minor.length)],vlc=rand(75)+25)
  sleep(rand(1)+1) # = 1 second of time 60 = minute
  midi.note_on(ch1=rand(8),note1=harmonic_minor[rand(harmonic_minor.length)],vlc=rand(75)+25)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_off(ch1,note1,0)
  midi.note_off(ch,note,0)
end
}

movement2 = Proc.new {
 10.times do
  puts "note" + " "+"#{cnt+=1}"
  midi.note_on(ch=rand(3),note= lydian_dominant[rand(lydian_dominant.length)],vlc=rand(75)+25)
  sleep(rand(1)+1) # = 1 second of time 60 = minute
  midi.note_on(ch1=rand(3),note1=harmonic_minor[rand(harmonic_minor.length)],vlc=rand(75)+25)
  midi.note_on(ch3=rand(3),note3=major[rand(major.length)],vlc=rand(75)+25)
  sleep(rand(1)+1) # = 1 second of time 60 = minute
  midi.note_on(ch2=rand(3),note2=marva[rand(marva.length)],vlc=rand(75)+25)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_off(ch1,note1,0)
  sleep(1)
  midi.note_off(ch,note,0)
  sleep(rand(1)+1)
  midi.note_off(ch2,note2,0)
  sleep(rand(2))
  midi.note_off(ch3,note3,0)
end
}

movement3 = Proc.new {
  6.times do
  puts "phrase pass" + " "+"#{cnt+=1}"
  midi.note_on(ch=1,note=major[rand(major.length)],vlc=rand(75)+25)
  sleep(1) # = 1 second of time 60 = minute
  midi.note_off(ch,note,0)
  end
}


# Idea here was to have a setup that combines instrumentation with rhythmn 
movement4 = Proc.new {
  
   16.times do 
    puts "note" + " "+"#{cnt+=1}"
    midi.note_on(ch=0,note=major[rand(major.length)],vlc=rand(75)+25)
    sleep(1) # = 1 second of time 60 = minute
    midi.note_off(ch,note,0)
  end
  
  32.times do
   puts "note" + " "+"#{cnt+=1}"
   midi.note_on(ch1=rand(3),note1=harmonic_minor[rand(harmonic_minor.length)],vlc=rand(75)+25)
   midi.note_on(ch3=rand(3),note3=major[rand(major.length)],vlc=rand(75)+25)
   midi.note_on(ch=5,note5=major[rand(major.length)],vlc=100)
   sleep(1) # = 1 second of time 60 = minute
   midi.note_on(ch=6,note6=major[rand(major.length)],vlc=100)
   sleep(1) # = 1 second of time 60 = minute
   sleep(rand(1)+1) # = 1 second of time 60 = minute
   midi.note_on(ch2=rand(3),note2=marva[rand(marva.length)],vlc=rand(75)+25)
   sleep(1) # = 1 second of time 60 = minute
   midi.note_off(ch1,note1,0)
   midi.note_on(ch=7,note7=major[rand(major.length)],vlc=100)
   midi.note_off(ch,note5,0)
   sleep(1) # = 1 second of time 60 = minute
   midi.note_on(ch=8,note8=major[rand(major.length)],vlc=100)
   midi.note_off(ch,note6,0)
   midi.note_off(ch,note7,0)
   midi.note_off(ch,note8,0)
   sleep(1)
   sleep(rand(1)+1)
   midi.note_off(ch2,note2,0)
   sleep(rand(2))
   midi.note_off(ch3,note3,0)
  end
  
  16.times do
   puts "phrase pass" + " "+"#{cnt+=1}"
   midi.note_on(ch=1,note=major[rand(major.length)],vlc=rand(75)+25)
   midi.note_on(ch=7,note7=major[rand(major.length)],vlc=100)
   midi.note_off(ch,note,0)
   midi.note_on(ch=1,note=major[rand(major.length)],vlc=rand(75)+25)
   midi.note_off(ch,note,0)
   sleep(1) # = 1 second of time 60 = minute
   midi.note_on(ch=8,note8=major[rand(major.length)],vlc=100)
   sleep(1) # = 1 second of time 60 = minute
   midi.note_off(ch,note,0)
   midi.note_off(ch,note7,0)
   midi.note_off(ch,note8,0)
  end
}

###############################
# A SIMPLE SYSTEM FOR CALLING MOVEMENTS # 
###############################
  puts "single channel now playing"
 # single_channel.call
 
 # puts "playing 1st Movement"
 # movement1.call
 
 # puts "playing the 2nd Movement"
 # movement2.call
 
 # puts this is the 3rd Movement"
 #movement3.call
 
 # puts "Now Playing the 4th Movement"
  movement4.call
 
 #2 part Haromonies
 #two_part_harmonies.call
 
 # Rhythmn Patterns 
 #rhythm_01.call

# Ranomized_Movement and based on Random 
 randomized_movement.call

# Chord progression tests and Ideas 
 major_chord.call
