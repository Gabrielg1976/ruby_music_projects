#
# Shoes Minesweeper by que/varyform
#

require 'rubygems'
require 'midiator'
require 'cb-music-theory'

LEVELS = { :beginner => [9, 9, 10], :intermediate => [16, 16, 40], :expert => [30, 16, 99] }

class Field

  
  CELL_SIZE = 20
  COLORS = %w(#00A #0A0 #A00 #004 #040 #400 #000)
  
  class Cell
    attr_accessor :flag
    def initialize(aflag = false)
      @flag = aflag
    end
  end
  
  class Bomb < Cell
    attr_accessor :exploded
    def initialize(exploded = false)
      @exploded = exploded
    end
  end
  
  class OpenCell < Cell
    attr_accessor :number
    def initialize(bombs_around = 0)
      @number = bombs_around
    end
  end
  
  class MIDICell < Cell 
    attr_reader :action
    def initialize(action = nil)
      @action = action
	  end
  end
  
  
  class NoteOffCell < MIDICell
	def initialize
		@action = lambda { all_notes_off }
	end
  end
  
  class EmptyCell < Cell; end
  
  attr_reader :cell_size, :offset
  attr_accessor :midi, :root_note, :scale, :chord, :progression, :duration
  
  def initialize(app, level, opts = {})

  @app = app
	@root_note = Note.new("C")
	@scale = opts[:scale]
	@chord = :major_chord
	@progression = [1,2,3,4,5,6,7,8]
	@duration = 1
	@midi = opts[:midi]
  @midi.autodetect_driver
  @timer = opts[:timer] 
	@channel = 0
	#level = opts[:level]
	
    @field = []
    @w, @h, @bombs = LEVELS[level][0], LEVELS[level][1], LEVELS[level][2]
    @h.times { @field << Array.new(@w) { EmptyCell.new } }
    @game_over = false
    @width, @height, @cell_size = @w * CELL_SIZE, @h * CELL_SIZE, CELL_SIZE
    @offset = [(@app.width - @width.to_i) / 2, (@app.height - @height.to_i) / 2]
    #plant_bombs
	layout_cells
    @start_time = Time.now
  end



	def play_chord(midi_object,chord,channel,duration,velocity)
	  chord.note_values.each{|note|
	    midi_object.note_on(channel,note,velocity)
	  }
	  #sustain it a bit
	  sleep(duration)
	  #release the chord
	  chord.note_values.each{|note|
	    midi_object.note_off(channel,note,0)
	  }
	end

	def play_arpeggio(midi_object,chord,channel,duration,velocity)
	  arpeggio = chord.note_values
	  arpeggio = arpeggio - [arpeggio.last] + arpeggio.reverse
	  arpeggio.each{|note|
		midi_object.note_on(channel,note,velocity)
	    #sustain it a bit
	    sleep(duration)
	    midi_object.note_off(channel,note,0)
		}
	end

	def test_drive_chord(midi_object,root_note,scale,chord,progression,duration = 1)
	  chan=@channel
	  chords = progression.map{|deg|
	    root_note.send(scale).harmonized_chord(deg,chord)
	  }    
	  chords.each{|chord|
	    play_chord(midi_object,chord,chan,duration,rand(50)+50)
	  }
	end

	def test_drive_arpeggio(midi_object,root_note,scale,chord,progression,duration = 1)
	  chan=@channel
	  chords = progression.map{|deg|
	    root_note.send(scale).harmonized_chord(deg,chord)
	  }    
	  chords.each{|chord|
	    play_arpeggio(midi_object,chord,chan,duration,rand(50)+50)
	  }
	end

	  
  def total_time
    @latest_time = Time.now - @start_time unless game_over? || all_found?
    @latest_time
  end
  
  def click!(x, y)
    return unless cell_exists?(x, y)
    #return if has_flag?(x, y)
	self[x,y].action[Time.now.to_f] if self[x,y].is_a?(MIDICell)
    #return die!(x, y) if bomb?(x, y)
    #open(x, y)
    #discover(x, y) if bombs_around(x, y) == 0
  end  

  def flag!(x, y)
    return unless cell_exists?(x, y)
    self[x, y].flag = !self[x, y].flag unless self[x, y].is_a?(OpenCell)
  end  
  
  def game_over?
    @game_over 
  end
  
  def render_cell(x, y, color = "#AAA", stroke = true)
    @app.stroke "#666" if stroke
    @app.fill color
    @app.rect x*cell_size, y*cell_size, cell_size-1, cell_size-1
    @app.stroke "#BBB" if stroke
    @app.line x*cell_size+1, y*cell_size+1, x*cell_size+cell_size-1, y*cell_size
    @app.line x*cell_size+1, y*cell_size+1, x*cell_size, y*cell_size+cell_size-1
  end
  
  def render_flag(x, y)
    @app.stroke "#000"
    @app.line(x*cell_size+cell_size / 4 + 1, y*cell_size + cell_size / 5, x*cell_size+cell_size / 4 + 1, y*cell_size+cell_size / 5 * 4)
    @app.fill "#A00"
    @app.rect(x*cell_size+cell_size / 4+2, y*cell_size + cell_size / 5, 
      cell_size / 3, cell_size / 4)
  end
  
  def render_bomb(x, y)
    render_cell(x, y)
    if (game_over? or all_found?) then # draw bomb
      if self[x, y].exploded then
        render_cell(x, y, @app.rgb(0xFF, 0, 0, 0.5))
      end
      @app.nostroke
      @app.fill @app.rgb(0, 0, 0, 0.8)
      @app.oval(x*cell_size+3, y*cell_size+3, 13)
      @app.fill "#333"
      @app.oval(x*cell_size+5, y*cell_size+5, 7)
      @app.fill "#AAA"
      @app.oval(x*cell_size+6, y*cell_size+6, 3)
      @app.fill @app.rgb(0, 0, 0, 0.8)
      @app.stroke "#222"
      @app.strokewidth 2
      @app.oval(x*cell_size + cell_size / 2 + 2, y*cell_size + cell_size / 4 - 2, 2)
      @app.oval(x*cell_size + cell_size / 2 + 4, y*cell_size + cell_size / 4 - 2, 1)
      @app.strokewidth 1
    end
  end
  
  def render_number(x, y)
    render_cell(x, y, "#999", false)
    if self[x, y].number != 0 then
      @app.nostroke
      @app.para self[x, y].number.to_s, :left => x*cell_size + 3, :top => y*cell_size - 2, 
        :font => '13px', :stroke => COLORS[self[x, y].number - 1]
    end
  end
  
  
  def all_notes_off
  (0..127).each { |note| @midi.note_off(@channel,note,0) }
  end
  
  
  def paint
    0.upto @h-1 do |y|
      0.upto @w-1 do |x|
        @app.nostroke
        case self[x, y]
			
          when MIDICell then render_cell(x,y)
		  when EmptyCell then render_cell(x, y)
          when Bomb then render_bomb(x, y)
          when OpenCell then render_number(x, y)
        end
        render_flag(x, y) if has_flag?(x, y) && !(game_over? && bomb?(x, y))
      end
    end
  end  

  def bombs_left
    @bombs - @field.flatten.compact.reject {|e| !e.flag }.size
  end  

  def all_found?
    @field.flatten.compact.reject {|e| !e.is_a?(OpenCell) }.size + @bombs == @w*@h
  end  

  def reveal!(x, y)
    return unless cell_exists?(x, y)
    return unless self[x, y].is_a?(Field::OpenCell)
    if flags_around(x, y) >= self[x, y].number then
      (-1..1).each do |v|
        (-1..1).each { |h| click!(x+h, y+v) unless (v==0 && h==0) or has_flag?(x+h, y+v) }
      end
    end      
  end  
  
  private 
  
  def cell_exists?(x, y)
    ((0...@w).include? x) && ((0...@h).include? y)
  end
  
  def has_flag?(x, y)
    return false unless cell_exists?(x, y)
    return self[x, y].flag
  end
  
  def bomb?(x, y)
    cell_exists?(x, y) && (self[x, y].is_a? Bomb)
  end
  
  def can_be_discovered?(x, y)
    return false unless cell_exists?(x, y)
    return false if self[x, y].flag
    cell_exists?(x, y) && (self[x, y].is_a? EmptyCell) && !bomb?(x, y) && (bombs_around(x, y) == 0)
  end  
  
  def open(x, y)
    self[x, y] = OpenCell.new(bombs_around(x, y)) unless (self[x, y].is_a? OpenCell) or has_flag?(x, y)
  end
  
  def neighbors
    (-1..1).each do |col|
      (-1..1).each { |row| yield row, col unless col==0 && row == 0 }
    end  
  end
  
  def discover(x, y)
    open(x, y)
    neighbors do |col, row|
      cx, cy = x+row, y+col
      next unless cell_exists?(cx, cy)
      discover(cx, cy) if can_be_discovered?(cx, cy)
      open(cx, cy)
    end
  end  

  def count_neighbors
    return 0 unless block_given?
    count = 0
    neighbors { |h, v| count += 1 if yield(h, v) }
    count
  end
  
  def bombs_around(x, y)
    count_neighbors { |v, h| bomb?(x+h, y+v) }
  end
  
  def flags_around(x, y)
    count_neighbors { |v, h| has_flag?(x+h, y+v) }
  end
  
  def die!(x, y)
    self[x, y].exploded = true
    @game_over = true
  end

  def plant_bomb(x, y)
    self[x, y].is_a?(EmptyCell) ? self[x, y] = Bomb.new : false
  end
  
  def plant_bombs
    @bombs.times { redo unless plant_bomb(rand(@w), rand(@h)) }
  end

  def layout_cells

    #self[0,0] = NoteOffCell.new
    @w,@h = 4,4
    pads = @w * @h
    base_note = 36
    #actions = []
    #(0..pads-1).each do |n|
    #  actions[n] = lambda { |note_number| lambda { |function| function[note_number]| |
    #}

  (0..pads-1).each do |p|
      row = @h -(p/@h) - 1
      col = p % @w
      n = base_note + p
      #alert "col:#{col} row:#{row} note: #{n}"
      self[col,row] = MIDICell.new(lambda{ |start|
          @timer.at(start) { @midi.driver.note_on(n,0,100)}
          @timer.at(start + 5) { @midi.driver.note_off(n,0) }
          #@timer.at(@start) {@midi.play 60 + n}
      })
    end
  end
  
  def [](*args)
    x, y = args
    raise "Cell #{x}:#{y} does not exists!" unless cell_exists?(x, y)
    @field[y][x]
  end
  
  def []=(*args)
    x, y, v = args
    cell_exists?(x, y) ? @field[y][x] = v : false
  end
end
Shoes.app(
  :width => 730, 
  :height => 550, 
  :title => 'Shoes MPC-0') do

  def render_field
	clear do
      background rgb(50, 50, 90, 0.7)	   	  
      stack do @status = para :stroke => white end
      @field.paint
      para "Left click - open cell, right click - put flag, middle click - reveal empty cells", :top => 420, :left => 0, :stroke => white,  :font => "11px"
    end  
  end
  
  def new_game level
    
    @midi = MIDIator::Interface.new
    @timer = MIDIator::Timer.new(0.0147)
    @scale = Note.new("C").major_scale
    @degree = 1
    @field = Field.new self, level, :midi => @midi, :timer => @timer, :scale => @scale    
    

    #:level => self.level, :timer => self.timer, :midi => self.midi, :scale => self.scale


    translate -@old_offset.first, -@old_offset.last unless @old_offset.nil?
    translate @field.offset.first, @field.offset.last
    @old_offset = @field.offset
    render_field
  end
  
  new_game :beginner
  #animate(5) { @status.replace "Time: #{@field.total_time.to_i} Bombs left: #{@field.bombs_left}" }
  str = ''
  player = lambda { |notes|
    lambda { 
      @timer.at(lambda{Time.now.to_f}[]) { @midi.play notes }
    }[]
  }

  keypress do |k|
      
    case k
    when "0".."9"
      @degree = k.to_i
      if @degree == 0
        @degree = 10
      end
      player[@scale.degree(@degree).value]
    
    when '['
      @scale = Scale.new(@scale.root_note - 1,@scale.intervals)
    when ']'
      @scale = Scale.new(@scale.root_note + 1,@scale.intervals)
    when '-'
      @scale = Scale.new(@scale.root_note - 12,@scale.intervals)
    when '='
      @scale = Scale.new(@scale.root_note + 12,@scale.intervals)
    when 'q'
      @note = @scale.degree(1).value + 1
      player[@note]
    when 'w'
      @note = @scale.degree(2).value + 1
      player[@note]
    when 'e'
      @note = @scale.degree(3).value + 1
      player[@note]
    when 'r'
      @note = @scale.degree(4).value + 1
      player[@note]
    when 't'
      @note = @scale.degree(5).value + 1
      player[@note]
    when 'y'
      @note = @scale.degree(6).value + 1
      player[@note]
    when 'u'
      @note = @scale.degree(7).value + 1
      player[@note]
    when 'i'
      @note = @scale.degree(8).value + 1
      player[@note]
    when 'o'
      @note = @scale.degree(9).value + 1
      player[@note]
    when 'p'
      @note = @scale.degree(10).value + 1
      player[@note]

    when "b"  #harmonize a triad on whatever degree, the cheater button
      @notes = [2,4].map{|n| @scale.degree(@degree+n).value}
      player[@notes]
    when "m" #major = 0,4,7          
      @notes = [4,7].map{|n| @scale.degree(@degree).value + n }
      player[@notes]
    when "n"  #minor = 0,3,7          
      @notes = [3,7].map{|n| @scale.degree(@degree).value + n }
      player[@notes]
    when "," #diminished = 0,3,6          
      @notes = [3,6].map{|n| @scale.degree(@degree).value + n }
      player[@notes]
    when "." #augmented = 0,4,8          
      @notes = [4,8].map{|n| @scale.degree(@degree).value + n }
      player[@notes]
    when "j" #harmonized 7th off the degree
      @note = @scale.degree(@degree+6).value
      player[@note]
    when "k" #harmonized 9th off the degree
      @note = @scale.degree(@degree+8).value
      player[@note]
    when "l" #harmonized 11th off the degree
      @note = @scale.degree(@degree+10).value
      player[@note]
    when ";" #harmonized 13th off the degree
      @note = @scale.degree(@degree+12).value
      player[@note]
      #alert offset
      
      #@timer.at(Time.now.to_f) { @midi.play @scale.degree(@degree +2).value }
      #@timer.at(Time.now.to_f) { @midi.play @scale.degree(@degree +4).value }
      #@timer.at(Time.now.to_f) { @notes.each{|n| @midi.driver.note_on(0,n,100) } }
      #@timer.at(Time.now.to_f + 1) { @notes.each{|n| @midi.driver.note_off(0,n,0) } }
      
    end #case
  end #keypress do

  click do |button, x, y|
    next if @field.game_over? || @field.all_found?
    fx, fy = ((x-@field.offset.first) / @field.cell_size).to_i, ((y-@field.offset.last) / @field.cell_size).to_i
    @field.click!(fx, fy) if button == 1
    @field.flag!(fx, fy) if button == 2
    @field.reveal!(fx, fy) if button == 3

    #render_field
    #alert("Winner!\nTotal time: #{@field.total_time}") if @field.all_found?
    #alert("Bang!\nYou loose.") if @field.game_over?
  end
end
