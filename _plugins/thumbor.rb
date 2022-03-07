require "liquid"
require "ruby-thumbor"

module Jekyll
  module ThumborFilter
    def thumbor_srcset(url)
      config = Jekyll.sites.first.config['thumbor']

      image = Thumbor::Cascade.new(config['key'], url)
      image.no_upscale_filter()

      result = []
      config["sizes"].each do |size|
        image_url = image.width(size).generate
        result << "#{config['url']}#{image_url} #{size}w"
      end

      result.join(", ")
    end
  end
end

Liquid::Template.register_filter(Jekyll::ThumborFilter)
