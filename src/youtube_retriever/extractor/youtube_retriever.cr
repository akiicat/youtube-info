require "./info_extractor"

class YoutubeRetriever
  property video_id : String

  include InfoExtractor

  def initialize(url : String)
    @video_id = extract_id(url)
  end

  def self.dump_json(url : String)
    new(url).real_extract
  end

  def real_extract
    LOG.info "Downloading video webpage: #{@video_id}"
    url           = "https://www.youtube.com/embed/#{@video_id}"
    video_webpage = download_webpage(url)

    # video_info
    sts        = extract_sts(video_webpage)
    video_info = get_video_info(@video_id, sts)

    # decipherer steps
    player_url = extract_player_url(video_webpage)
    steps = Cache.load(player_url)
    if steps.empty?
      steps = Interpreter.decode_steps(player_url)
      Cache.store(player_url, steps)
    end
    decipher = Decipherer.new(steps: steps)

    rtn = {
      :title          => video_info["title"]?.to_s,
      :author         => video_info["author"]?.to_s,
      :thumbnail_url  => video_info["thumbnail_url"]?.to_s,
      :length_seconds => video_info["length_seconds"]?.to_s,
      :streams        => decipher.package(video_info["url_encoded_fmt_stream_map"]?.to_s) + decipher.package(video_info["adaptive_fmts"]?.to_s)
    }
  end
end
