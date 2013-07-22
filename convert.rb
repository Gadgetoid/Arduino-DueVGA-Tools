#!/usr/bin/env ruby

require 'chunky_png'
require 'trollop'

opts = Trollop::options do
	version "Arduino Due VGA BitMap Converter 1.0.0 - Philip Howard"
	banner <<-EOS
Convert 8-bit PNG files for use with the DueVGA library. With or without an indexed palette.

Usage:
	convert.rb [options] <filename>
EOS
	opt :file, "File", :type => String
	opt :width, "Width", :type => :int
	opt :height, "Height", :type => :int
	opt :palette, "Palette", :type => :string
end

#Trollop::die :width, "required" unless opts[:width]
Trollop::die :palette, "should be a comma-separated list of 16 colours" if opts[:palette].split(',').length < 16 if opts[:palette]
Trollop::die :file, "required" unless opts[:file]
Trollop::die :file, "must exist" unless File.exist?(opts[:file]) if opts[:file]

opts[:height] = opts[:width] unless opts[:height]

input_file = opts[:file] # ARGV[0]

file_width = opts[:width] # ARGV[1].to_i
file_height = opts[:height] # ARGV[2].to_i

@palette = [] 
@palette = opts[:palette].split(',') if opts[:palette]

@palette.map! do |col|
	col.to_i(16)
end


@png = ChunkyPNG::Image.from_file(input_file)

file_width = @png.width if file_width.nil?
file_height = @png.height if file_height.nil?

output_name = input_file.split('/').last.split('.').first.downcase

frame_count = @png.pixels.length / (file_width*file_height)

#@palette = [0xe3,0x24,0x07,0x06,0x01,0xff,0xe4,0xb6,0xfe,0x6d,0xa0,0x88,0xf5,0xcc,0xf8,0xf0]

@map = [0x000000ff,0x010553ff,0x0414a7ff,0x0b24fbff,0x012302ff,0x022554ff,0x062ba7ff,0x0c34fbff,0x054706ff,0x064854ff,0x094ba7ff,0x0f50fbff,0x0b6b0dff,0x0c6b55ff,0x0f6da8ff,0x1371fbff,0x128f16ff,0x138f57ff,0x1590a9ff,0x1993fcff,0x1ab21eff,0x1ab359ff,0x1cb4a9ff,0x1fb5fcff,0x21d626ff,0x22d65cff,0x23d7abff,0x25d8fdff,0x29fa2eff,0x29fa5fff,0x2afaacff,0x2cfcfeff,
		0x230001ff,0x240653ff,0x2514a7ff,0x2724fbff,0x242402ff,0x242554ff,0x252ba7ff,0x2834fbff,0x254706ff,0x254854ff,0x274ba7ff,0x2950fbff,0x276b0eff,0x286b55ff,0x296da8ff,0x2b71fbff,0x2a8f16ff,0x2b8f57ff,0x2c90a9ff,0x2d93fcff,0x2eb21eff,0x2eb359ff,0x2fb4a9ff,0x31b5fcff,0x33d626ff,0x33d65cff,0x34d7abff,0x35d8fdff,0x38fa2eff,0x38fa5fff,0x39faacff,0x3afcfeff,
		0x470102ff,0x470654ff,0x4815a7ff,0x4924fbff,0x472404ff,0x472654ff,0x482ba7ff,0x4935fbff,0x484708ff,0x484855ff,0x494ba7ff,0x4a50fbff,0x496b0fff,0x496c56ff,0x4a6da8ff,0x4b71fbff,0x4b8f17ff,0x4b8f57ff,0x4b90a9ff,0x4c93fcff,0x4db21fff,0x4db359ff,0x4db4aaff,0x4eb5fcff,0x4fd627ff,0x4fd65cff,0x50d7abff,0x51d8fdff,0x52fa2eff,0x52fa5fff,0x53faacff,0x54fcfeff,
		0x6b0206ff,0x6b0754ff,0x6b15a7ff,0x6c25fbff,0x6b2407ff,0x6b2654ff,0x6b2ca7ff,0x6c35fbff,0x6b480bff,0x6b4855ff,0x6c4ba8ff,0x6c51fbff,0x6c6b12ff,0x6c6c56ff,0x6c6da8ff,0x6d71fbff,0x6d8f18ff,0x6d8f58ff,0x6d90a9ff,0x6e93fcff,0x6eb220ff,0x6eb35aff,0x6fb4aaff,0x6fb5fcff,0x70d628ff,0x70d65cff,0x70d7abff,0x71d8fdff,0x72fa2fff,0x72fa60ff,0x72faadff,0x73fcfeff,
		0x8e040aff,0x8e0955ff,0x8f16a8ff,0x8f25fbff,0x8e250cff,0x8e2755ff,0x8f2ca8ff,0x8f35fbff,0x8f480fff,0x8f4956ff,0x8f4ca8ff,0x8f51fbff,0x8f6b15ff,0x8f6c57ff,0x8f6ea8ff,0x9071fbff,0x908f1bff,0x908f58ff,0x9091a9ff,0x9193fcff,0x91b222ff,0x91b35aff,0x91b4aaff,0x92b6fcff,0x92d629ff,0x92d65dff,0x92d7abff,0x93d9fdff,0x93fa31ff,0x94fa60ff,0x94fbadff,0x94fcfeff,
		0xb20610ff,0xb20b56ff,0xb218a8ff,0xb326fbff,0xb22611ff,0xb22756ff,0xb22da8ff,0xb336fbff,0xb24814ff,0xb24957ff,0xb24ca8ff,0xb351fbff,0xb36c18ff,0xb36c58ff,0xb36ea9ff,0xb371fcff,0xb38f1eff,0xb38f59ff,0xb391a9ff,0xb493fcff,0xb4b324ff,0xb4b35bff,0xb4b4aaff,0xb4b6fdff,0xb5d62bff,0xb5d65eff,0xb5d7acff,0xb5d9fdff,0xb6fa32ff,0xb6fa61ff,0xb6fbadff,0xb6fcfeff,
		0xd60915ff,0xd60e57ff,0xd619a8ff,0xd627fbff,0xd62716ff,0xd62857ff,0xd62ea9ff,0xd636fcff,0xd64918ff,0xd64a58ff,0xd64da9ff,0xd652fcff,0xd66c1cff,0xd66c59ff,0xd66ea9ff,0xd672fcff,0xd68f21ff,0xd6905aff,0xd791aaff,0xd793fcff,0xd7b327ff,0xd7b35cff,0xd7b4abff,0xd7b6fdff,0xd8d62eff,0xd8d75fff,0xd8d7acff,0xd8d9feff,0xd9fa34ff,0xd9fa62ff,0xd9fbaeff,0xd9fcffff,
		0xf90d1bff,0xf91158ff,0xf91ba9ff,0xfa28fcff,0xf9281cff,0xf92a58ff,0xf92fa9ff,0xfa37fcff,0xf9491eff,0xf94a59ff,0xf94da9ff,0xfa52fcff,0xfa6c21ff,0xfa6d5aff,0xfa6faaff,0xfa72fcff,0xfa8f25ff,0xfa905cff,0xfa91abff,0xfa94fdff,0xfab32aff,0xfab35eff,0xfbb4acff,0xfbb6fdff,0xfbd630ff,0xfbd760ff,0xfbd7adff,0xfbd9feff,0xfcfa37ff,0xfcfa63ff,0xfcfbaeff,0xffffffff]


if @palette.length > 0
	byte_count = (@png.pixels.length/2) + 3

	@output = ''

	@png.pixels.each do |pixel|
		col = @map.index(pixel)
		col = @palette.index(col).to_i

		@output << col.to_s(2).rjust(4,"0")
	end	

	@new_output = []

	@output.split('').each_slice(8) do |slice|

		@new_output <<  '0x' + slice.join.to_i(2).to_s(16).rjust(2,'0')

	end

	@final_output = []

	@new_output.each_slice(file_width/2) do |slice| 
		@final_output << slice.join(',')
	end

	meta = [
		file_width,
		file_height,
		frame_count
	]
	meta = meta.join(",\n\t")

	# Drop the zero index, this is reserved for transparency
	@palette.shift

	@palette.map! do |col|
		'0x' + col.to_s(16).rjust(2,'0')
	end

	puts 'static unsigned char ' + output_name + '_palette[15] = {' + @palette.join(',') + '}';

	puts 'static unsigned char ' + output_name + '[' + byte_count.to_s + "] = {\n\t" + meta + ",\n" + @final_output.join(",\n") + '};'

else
	byte_count = @png.pixels.length

	@output = []

	@png.pixels.each do |pixel|
		col = @map.index(pixel)

		@output << "0x" + col.to_s(16).rjust(2,"0")
	end	

	@new_output = []

	@output.each_slice(file_width) do |slice|

		@new_output << "\t" + slice.join(',')

	end

	puts 'static unsigned char ' + output_name + '[' + byte_count.to_s + "] = {\n" + @new_output.join(",\n") + '};'

end