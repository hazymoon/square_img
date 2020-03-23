# frozen_string_literal: true

require "bundler"
Bundler.require

path = File.expand_path(ARGV[0], __FILE__)
border_color = if ARGV[1].nil?
                 "black"
               else
                 ARGV[1]
               end

Dir.open(path) do |entry|
  image_files = entry.select { |file| file.match(/\.(jpe?g|png|bmp|gif|tiff)$/i) }
  Parallel.each(image_files) do |image|
    image_path = File.join(path, image)
    image = MiniMagick::Image.open(image_path)

    width, height = image.dimensions
    diff = width - height

    next if diff.zero?

    MiniMagick::Tool::Convert.new do |convert|
      convert << image_path
      convert.merge! %W[-bordercolor #{border_color}]
      if diff > 0
        # 画像の幅の方が大きいので、差分を上下の増分として足す
        convert.merge! %W[-border 0x#{diff / 2}x0]
      elsif diff < 0
        # 画像の高さの方が大きいので、差分を左右の増分として足す
        convert.merge! %W[-border #{diff.abs / 2}x0x0]
      end
      convert << image_path
    end
  end
end
