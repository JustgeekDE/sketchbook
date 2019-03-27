#!/usr/bin/env ruby

require "prawn"
require "json"



Prawn::Document.generate("sketchbook.pdf", :page_size => "A6") do

  text "Simple Sketchbook", :valign => :center, :align => :center, :size => 20


  json_string = File.read "content.json"
  content = JSON.parse(json_string)
  content['pages'].each do | page |
    start_new_page

    box_width = 100
    image_size = 50

    text_right_corner = margin_box.width - box_width
    image_right_corner = margin_box.width - image_size
    is_even = page_number % 2 == 0

    text_x = if is_even then text_right_corner.round else 0 end
    image_x = if is_even then image_right_corner.round else 0 end
    alignment = if is_even then :right else :left end
    image_y = margin_box.height
    text_y = image_y - image_size

    image "images/#{page['image']}",
          :at => [image_x, image_y],
          :width => image_size,
          :height => image_size

    text_box page['description'],
                 :at => [text_x, text_y],
                 :align  => alignment,
                 :width  => box_width,
                 :size => 8
  end
end
