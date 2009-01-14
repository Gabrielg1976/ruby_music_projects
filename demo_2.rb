require'music'
require'scales'
count=0

# Tryout with a four channel monotone setup

midi = LiveMIDI.new 
 
a,b,d,e=rand(52)+33,rand(52)+33,rand(52)+33,rand(52)+33

3.times {
if a > b
    puts "Phrase 1"
    a.times do
    count +=1
    midi.note_on(ch=rand(4),nt=persian[rand(persian.length)],vlc=rand(75)+25)
    sleep(rand(3)) # = 1 second of time 60 = minute
    midi.note_off(ch,nt,0)
    end
else
    puts "Phrase 2"
    b.times do
      count+=1
      midi.note_on(ch=rand(4),nt=leading_whole_tone[rand(leading_whole_tone.length)],vlc=rand(75)+25)
     sleep(rand(2)+1)# = 1 second of time 60 = minute
      midi.note_off(ch,nt,0)
      end
end
if d > e
    puts "Phrase 3"
    e.times do
      count +=1
      midi.note_on(ch=rand(4),nt=hungarian_gypsy[rand(hungarian_gypsy.length)],vlc=rand(75)+25)
      sleep(rand(3))# = 1 second of time 60 = minute
      midi.note_off(ch,nt,0)
      end
else
    puts "Phrase 4"
    d.times do
    count+=1
    midi.note_on(ch=rand(4),nt=mixolydian_aug[rand(mixolydian_aug.length)],vlc=rand(75)+25)
    sleep(rand(2)+1)# = 1 second of time 60 = minute
    midi.note_off(ch,nt,0)
    end
end
}
puts "The Composition is Finished"
puts "The Total number of Notes Generated was" + " " + "#{count}"