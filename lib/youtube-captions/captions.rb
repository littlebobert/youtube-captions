require 'httparty'
require 'cgi'

module YoutubeCaptions
  class Captions
    include HTTParty

    attr_reader :info, :lang
    def initialize(info:, lang:)
      @info = info
      @lang = lang
    end

    def call
      if lang.nil?
        lang_info = default_lang_info
      else
        lang_info = search_lang_info
      end

      return raise LangNotAvailableError.new("Lang no available") unless lang_info_has_base_url?(lang_info)

      response = self.class.get(lang_info["baseUrl"])
      captions = response["transcript"]["text"]

      clean_captions(captions)
    end

    private

    def default_lang_info
      info.find {|json| json["kind"] != "asr" } || info.first
    end

    def search_lang_info
      info.find { |json| json["vssId"] == ".#{lang}" && json["kind"] != "asr" } || info.find {|json| json["vssId"] == "a.#{lang}" && json["kind"] != "asr" }
    end

    def lang_info_has_base_url?(lang_info)
      lang_info && lang_info["baseUrl"]
    end

    def clean_captions(captions)
      captions.map do |caption|
        caption.tap { |caption_hash|
          parameter = caption_hash.key?("__content__") ? caption_hash["__content__"] : nil
          next if parameter.nil?
          caption_hash["__content__"] = CGI.unescapeHTML(parameter).split.join(" ")
        }
      end
    end
  end
end
