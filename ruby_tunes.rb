# ruby_tunes
# built on the shoulders of giants ( ruby_music_projects, practical_ruby_projects,
# midiator,
require 'music'

class TunesConfig
  attr_accessor :channel

  def initialize(channel)
    @channel = channel
  end
end

class TunePlayer
  attr_accessor :channel

  def initialize(channel)
    @channel = channel
  end

  def play(note, len = 0.5)
  if(note.class == Array) then
    note.each { |n|
      if(n.class == Array) then
        n.each { |chord_note|
          MainMidi.note_on(@channel,chord_note,100)
        }
        sleep(len)
        n.each { |chord_note|
          MainMidi.note_off(@channel,chord_note,0)

        }
      else
        MainMidi.note_on(@channel,n,100)
        sleep(len)
        MainMidi.note_off(@channel,n,0)
      end
    }
    return
  end
  MainMidi.note_on(@channel,note,100)
  sleep(len)
  MainMidi.note_off(@channel,note,0)
end

def instrument(inst)
  MainMidi.program_change(@channel, inst)
end

end

MainMidi = LiveMIDI.new
Configs = TunesConfig.new 1

def play(note, len = 0.5)
  if(note.class == Array) then
    note.each { |n|
      if(n.class == Array) then
        n.each { |chord_note|
          MainMidi.note_on(Configs.channel,chord_note,100)
        }
        sleep(len)
        n.each { |chord_note|
          MainMidi.note_off(Configs.channel,chord_note,0)
          
        }
      else
        MainMidi.note_on(Configs.channel,n,100)
        sleep(len)
        MainMidi.note_off(Configs.channel,n,0)
      end
    }
    return
  end
  MainMidi.note_on(Configs.channel,note,100)
  sleep(len)
  MainMidi.note_off(Configs.channel,note,0)
end

def instrument(inst)
  MainMidi.program_change(Configs.channel, inst)
end

