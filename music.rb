# LiveMIDI from the Practal Ruby Projects by Topher Cyll
# Released under the Guidelines stated in the MIT Licences
# http://www.linfo.org/mitlicense.html   
# This a Mac Only Version Currently 
require 'dl/import' 

if RUBY_PLATFORM.include?('darwin') 

 class NoMIDIDestinations < Exception; end 
 
 module Enumerable
   def rest
     return [] if empty?
     self[1..-1]
   end
 end
 
class LiveMIDI 
    
ON  = 0x90 
OFF = 0x80 
PC  = 0xC0 

 attr_reader :interval
 
 @@singleton = nil
 def self.use(bpm=120)
   return @@singleton = self.new(bpm) if @@singleton.nil?
   @@singleton.bpm = bpm
   @@singleton.reset
   return @@singleton
 end

 def initialize(bpm=180)
   self.bpm = bpm
   @timer = Timer.get(@interval/10)
   @channel_manager = ChannelManager.new(16)
   open
 end

 def bpm=(bpm)
   @interval = 60.0 / bpm
 end
 


 def instrument(preset, channel=nil)
   channel = @channel_manager.allocate(channel)
   program_change(channel, preset)
   return Instrument.new(self, channel)
 end

 def reset
   @channel_manager.reset
 end


 def play(channel, note, duration, velocity=100, time=nil)
   on_time = time || Time.now.to_f
   @timer.at(on_time) { note_on(channel, note, velocity) }
   
   off_time = on_time + duration
   @timer.at(off_time) { note_off(channel, note, velocity) }
 end

 def note_on(channel, note, velocity=64)
   puts "NOTE ON  (#{Time.now.to_f}) #{channel} #{note} #{velocity}"
   message(ON | channel, note, velocity)
 end

 def note_off(channel, note, velocity=64)
   puts "NOTE OFF (#{Time.now.to_f}) #{channel} #{note} #{velocity}"
   message(OFF | channel, note, velocity)
 end

 def program_change(channel, preset)
   message(PC | channel, preset)
 end

  module C 
  extend DL::Importable 
   dlload '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI' 
   extern "int MIDIClientCreate(void *, void *, void *, void *)" 
   extern "int MIDIClientDispose(void *)" 
   extern "int MIDIGetNumberOfDestinations()" 
   extern "void * MIDIGetDestination(int)" 
   extern "int MIDIOutputPortCreate(void *, void *, void *)" 
   extern "void * MIDIPacketListInit(void *)" 
   extern "void * MIDIPacketListAdd(void *, int, void *, int, int, int, void *)" 
   extern "int MIDISend(void *, void *, void *)" 
  end 
  
  module CF 
  extend DL::Importable 
  dlload '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation' 
  extern "void * CFStringCreateWithCString (void *, char *, int)" 
  end 
  
  def open 
  client_name = CF.cFStringCreateWithCString(nil, "RubyMIDI", 0) 
  @client = DL::PtrData.new(nil) 
  C.mIDIClientCreate(client_name, nil, nil, @client.ref); 
  port_name = CF.cFStringCreateWithCString(nil, "Output", 0) 
  @outport = DL::PtrData.new(nil) 
  C.mIDIOutputPortCreate(@client, port_name, @outport.ref); 
  num = C.mIDIGetNumberOfDestinations() 
  raise NoMIDIDestinations if num < 1 
  @destination = C.mIDIGetDestination(0) 
  end 
  
  def close 
  C.mIDIClientDispose(@client) 
  end 
  
  def message(*args) 
    format = "C" * args.size 
    bytes = args.pack(format).to_ptr 
    packet_list = DL.malloc(256) 
    packet_ptr  = C.mIDIPacketListInit(packet_list) 
    # Pass in two 32 bit 0s for the 64 bit time 
    packet_ptr  = C.mIDIPacketListAdd(packet_list, 256, packet_ptr, 0, 0, 
    args.size, bytes) 
    C.mIDISend(@outport, @destination, packet_list) 
  end 
end 
 else 
  raise "Couldn't find a LiveMIDI implementation for your platform" 
end

# Extra Features added to the below Section Dont edit Above this Line !!!!
class ChannelManager
  def initialize(total)
    @total = total
    reset
  end

  def reset
    @channels = (0...@total).to_a
  end

  def allocate(channel=nil)
    raise "No channels left to allocate" if @channels.empty?
    return @channels.shift if channel.nil?
    raise "Channel unavailable" unless @channels.include?(channel)
    @channels.delete(channel)
    return channel
  end

  def release(channel)
    @channels.push(channel)
    @channels.sort!
  end
end

class Timer
  def self.get(interval)
    @timers ||= {}
    return @timers[interval] if @timers[interval]
    return @timers[interval] = self.new(interval)
  end

  def initialize(resolution)
    @resolution = resolution
    @queue = []

    Thread.new do
      while true
        dispatch
        sleep(@resolution)
      end
    end
  end

  def at(time, &block)
    time = time.to_f if time.kind_of?(Time)
    @queue.push [time, block]
  end

  private
  def dispatch
    now = Time.now.to_f
    ready, @queue = @queue.partition{|time, proc|  time <= now }
    ready.each {|time, proc| proc.call(time) }
  end
end

class Metronome
  def initialize(bpm)
    @midi = LiveMIDI.new
    @midi.program_change(0, 115)
    @interval = 60.0 / bpm
    @timer = Timer.get(@interval/10)
    now = Time.now.to_f
    register_next_bang(now)
  end
	
  def register_next_bang(time)
    @timer.at(time) do |this_time|
      register_next_bang(this_time + @interval)
      bang
    end
  end

  def bang
    @midi.play(0, 84, 0.1, 100, Time.now.to_f + 0.2)
  end
end

class Monitor
  def initialize(filename)
    raise "File doesn't exist" if ! File.exists?(filename)
    raise "Can't read file"    if ! File.readable?(filename)
    
    # Reload timer is independent of other times - every half second should be fine
    @timer = Timer.get(0.5) 
    @filename = filename
    @bangs = 0
    @players = [ Player.new() ]
    
    load
  end

  def load()
    code = File.open(@filename) {|file| file.read }

    dup = @players.last.dup
    begin
      dup.reset
      dup.instance_eval(code)
      @players.push(dup)
    rescue
      puts "LOAD ERROR: #{$!}"
    end

    @load_time = Time.now.to_i
  end

  def modified?
    return File.mtime(@filename).to_i > @load_time
  end

  def run(now=nil)
    now ||= Time.now.to_f
    load() if modified?

    begin
      @players.last.on_bang(@bangs)
    rescue
      puts "RUN ERROR: #{$!}"
      @players.pop
      retry unless @players.empty?
    end

    @bangs += 1

    @timer.at(now + @players.last.tick) {|time| run(time) }
  end

  def run_forever
    run
    sleep(10) while true
  end
end


