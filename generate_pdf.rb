#!/usr/bin/env ruby

require "prawn"
require "json"
require "yaml"


def title_page(pdf)
  commit = `git rev-parse --short HEAD`.chomp

  pdf.text "Simple Sketchbook", :valign => :center, :align => :center, :size => 20
  pdf.start_new_page
  pdf.text "Version: #{commit}", :valign => :bottom, :align => :left, :size => 6

end

class SinglePageLeft
  @@box_width = 100
  @@image_size = 50

  def initialize(description, image, margin_box)
    @description = description
    @image = image

    image_y = margin_box.height

    @image_position = [0, image_y]
    @text_position = [0, image_y - @@image_size]
    @alignment = :left
  end

  def render(pdf)
    pdf.start_new_page

    pdf.image "images/#{@image}",
          :at => @image_position,
          :width => @@image_size,
          :height => @@image_size

    pdf.text_box @description,
             :at => @text_position,
             :align => @alignment,
             :width => @@box_width,
             :size => 8
  end
end

class SinglePageRight < SinglePageLeft
  def initialize(description, image, margin_box)
    @description = description
    @image = image

    image_y = margin_box.height
    image_x = margin_box.width - @@image_size
    text_x = margin_box.width - @@box_width

    @image_position = [image_x, image_y]
    @text_position = [text_x, image_y - @@image_size]
    @alignment = :right
  end

end


Prawn::Document.generate("sketchbook.pdf", :page_size => "A6") do |pdf|

  title_page(pdf)


  content = YAML.load_file('content.yml')
  content['pages'].each do | page |
    description = page['description']
    image_name = page['image']

    page = if pdf.page_number % 2 == 0 then
               SinglePageLeft.new(description, image_name, pdf.margin_box)
             else
               SinglePageRight.new(description, image_name, pdf.margin_box)
           end
    page.render(pdf)
  end
end
