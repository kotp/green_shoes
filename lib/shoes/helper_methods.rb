class Shoes
  class App
    def basic_attributes args={}
      default = {left: 0, top: 0, width: 0, height: 0}
      default.merge args
    end

    def slot_attributes args={}
      default = {left: nil, top: nil, width: 1.0, height: 0}
      default.merge args
    end

    def create_tmp_png surface
      surface.write_to_png TMP_PNG_FILE
      Gtk::Image.new TMP_PNG_FILE
    end
  end

  def self.contents_alignment slot
    x, y = slot.left.to_i, slot.top.to_i
    max = Struct.new(:top, :height).new
    max.top, max.height = y, 0
    slot_height = 0

    slot.contents.each do |ele|
      tmp = max
      max = ele.positioning x, y, max
      x, y = ele.left + ele.width, ele.top + ele.height
      slot_height += max.height unless max == tmp
    end
    slot_height
  end

  def self.repaint_all slot
    slot.contents.each do |ele|
      ele.is_a?(Basic) ? ele.move2(ele.left, ele.top) : repaint_all(ele)
    end
  end
  
  def self.call_back_procs app
    init_contents app.cslot.contents
    app.cslot.width, app.cslot.height = app.width, app.height
    contents_alignment app.cslot
    repaint_all app.cslot
    true
  end

  def self.init_contents contents
    contents.each do |ele|
      next unless ele.is_a? Slot
      ele.initials.each do |k, v|
        ele.send "#{k}=", v
      end
    end
  end

  def self.mouse_click_control app
    app.mccs.each do |e|
      mouse_x, mouse_y = e.real.pointer
      e.proc.call if ((0..e.width).include?(mouse_x) and (0..e.height).include?(mouse_y))
    end
  end
end