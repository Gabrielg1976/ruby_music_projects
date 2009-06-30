# Live Movements ( Live Ruby Music Coding )
# Designed by Gabriel Garrod
# June 2009 

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require'music'
require'scales'

# Created 3 different sections for mapping over a mixing board
sect_1=[0,1,2,3]
sect_2=[4,5,6,7]
sect_3=[8,9,10,11]

midi = LiveMIDI.new

m_1 = Proc.new {
  64.times {
  midi.note_on(ch=sect_1[rand(sect_1.size)],nt=major[rand(major.length)],vlc=rand(75)+25)
  puts "#{nt}"
  sleep(rand(3)) # = 1 second of time 60 = minute
  midi.note_off(ch,nt,0) }
}

# The Last 4 channels 
m_2 = Proc.new {
  64.times {
  midi.note_on(ch=sect_2[rand(sect_2.size)],nt=todi[rand(todi.length)],vlc=rand(75)+25)
  puts "#{nt}"
  sleep(rand(3)) # = 1 second of time 60 = minute
  midi.note_off(ch,nt,0) }
}

m_1.call 
m_2.call



