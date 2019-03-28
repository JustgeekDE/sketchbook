#!/usr/bin/env ruby

require "prawn"
require "json"
require "yaml"


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


class DoublePage < SinglePageLeft

  def render(pdf)
    pdf.start_new_page

    unless pdf.page_number % 2 == 0
      pdf.start_new_page
    end

    pdf.image "images/#{@image}",
              :at => @image_position,
              :width => @@image_size,
              :height => @@image_size

    pdf.text_box @description,
                 :at => @text_position,
                 :align => @alignment,
                 :width => @@box_width,
                 :size => 8
    pdf.start_new_page
  end
end


class TitlePage
  def render(pdf)
    commit = `git rev-parse --short HEAD`.chomp

    pdf.text "Simple Sketchbook", :valign => :center, :align => :center, :size => 20
    pdf.start_new_page
    pdf.text "Version: #{commit}", :valign => :bottom, :align => :left, :size => 6
  end
end

class OverviewPage
  @@image_size = 30

  def initialize(content)
    @content = content
  end

  def render(pdf)
    margin_height = pdf.margin_box.height

    pdf.start_new_page
    pdf.text "Overview", :valign => :top, :align => :center, :size => 16

    image_y = margin_height - 30
    image_x = 0

    @content['pages'].each do |page|
      image_name = page['image']


      pdf.image "images/#{image_name}",
                :at => [image_x, image_y],
                :width => @@image_size,
                :height => @@image_size

      image_x = image_x + @@image_size

      if image_x > pdf.margin_box.width - @@image_size then
        image_x = 0

        image_y = image_y - @@image_size
        if image_y < @@image_size then
          image_y = margin_height
          pdf.start_new_page
        end
      end
    end
  end
end

Prawn::Document.generate("sketchbook.pdf", :page_size => "A6") do |pdf|

  content = YAML.load_file('content.yml')

  TitlePage.new.render(pdf)
  OverviewPage.new(content).render(pdf)


  content['pages'].each do | page |
    description = page['description']
    image_name = page['image']
    double_wide = page['double']

    if double_wide then
      DoublePage.new(description, image_name, pdf.margin_box).render(pdf)
    else
      page = if pdf.page_number % 2 == 0 then
               SinglePageRight.new(description, image_name, pdf.margin_box)
             else
               SinglePageLeft.new(description, image_name, pdf.margin_box)
             end
      page.render(pdf)
    end

  end
end
