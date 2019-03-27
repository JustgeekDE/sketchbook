#!/usr/bin/env ruby

require "prawn"
require "json"



Prawn::Document.generate("sketchbook.pdf", :page_size => "A6") do

  text "Simple Sketchbook", :valign => :center, :align => :center, :size => 20

  #print margin_box.width

  json_string = File.read "content.json"
  content = JSON.parse(json_string)
  content['pages'].each do | page |
    start_new_page

    box_width = 120
    right_start = margin_box.width - box_width
    position = if page_number % 2 == 0 then right_start.round else 0 end

    text_box page['description'],
                 :at => [position, margin_box.height],
                 :align  => :left,
                 :width  => box_width,
                 :size => 9
  end
end
