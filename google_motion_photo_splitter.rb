#!/usr/bin/env ruby

# Android motion photo file splitter --
# saves the raw JPG image and MP4 video to separate files

unless (file_with_path = ARGV.first)
    puts "Pass a path to a file, please"
    exit
end

folder = File.dirname(file_with_path)
base_filename = File.basename(file_with_path, File.extname(file_with_path))

unless %w(.jpg .jpeg).include? File.extname(file_with_path).downcase
    puts "This is not a .jpg or .jpeg file"
    exit
end

puts "Processing: #{file_with_path}"

data = File.read(file_with_path, mode: 'rb')

unless (mp4_ftyp_atom_pos = data.index("ftyp"))
    puts "No MP4 identifying tag found in file"
    exit
end

mp4_start_pos = mp4_ftyp_atom_pos - 4
unless (jpg_end_tag_pos = data.rindex(0xff.chr + 0xd9.chr, mp4_start_pos))
    puts "MP4 start found, but no JPG end found in file"
    exit
end

jpg_end_pos = jpg_end_tag_pos + 2
puts "Index points found!  JPG from start to #{jpg_end_pos}; MP4 from #{mp4_start_pos} to end"

photo_file_with_path = folder + File::SEPARATOR + base_filename + "_photo.jpg"
puts "Saving photo to #{photo_file_with_path}..."
File.write(photo_file_with_path, data[0..jpg_end_pos])

video_file_with_path = folder + File::SEPARATOR + base_filename + "_video.mp4"
puts "Saving video to #{video_file_with_path}..."
File.write(video_file_with_path, data[mp4_start_pos..-1])
