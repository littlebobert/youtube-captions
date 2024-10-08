require 'nokogiri'
require 'open-uri'

module YoutubeCaptions
  class Info

    attr_reader :id
    def initialize(id:)
      @id = id
    end

    def call
      puts "connecting"
      youtube_html = Nokogiri::HTML(URI.open("#{YoutubeCaptions::YOUTUBE_VIDEO_URL}#{id}")).inner_html
      puts "received html: #{youtube_html}"
      match_data = youtube_html.match(YoutubeCaptions::CAPTIONABLE_REGEX)
      puts "found matches: #{match_data}"
      return raise NoCaptionsAvailableError.new("No captions available") unless match_data
      puts "returning #{match_data[1]}"
      JSON.parse(match_data[1])
    end
  end
end
