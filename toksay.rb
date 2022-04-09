require 'net/http'
require 'uri'
require 'json'
require 'optparse'
require 'tempfile'

options = {mode: :play}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #$0 text to say"

  opts.on("-p", "--play", "play audio (default)") do |f|
    options[:mode] = :play
  end

  opts.on("-sFILE", "--save=FILE", "save to file") do |f|
    options[:mode] = :save
    options[:filename] = f
  end
end

opts.parse!

if ARGV.empty?
  puts opts
  exit 1
end

text = ARGV.join(" ")

BASE_URL = "https://api16-normal-useast5.us.tiktokv.com/media/api/text/speech/invoke/?text_speaker=en_us_002&"
uri = URI.parse("#{BASE_URL}#{URI.encode_www_form(req_text: text)}")
request = Net::HTTP::Post.new(uri)

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

raise response.body unless response.code == '200'

data = JSON.parse(response.body)

v_str = data["data"]["v_str"]
v = v_str.unpack1("m")

case options[:mode]
when :play
  Tempfile.create(['toksay', '.mp3']) do |f|
    f.write(v)
    system("afplay", f.path)
  end
when :save
  file = options.fetch(:filename)
  File.write(file, v)
end
