require "classanator/version"

module Classanator
  class Deck

    def render
      inject('') do |m, slide|
        m + slide_markup do
          slide.content
        end
      end
    end

    def test
      each do |slide|
        next unless slide.test
        system(slide.test)
        print "(slide #{slide.position}) "
        if $? == 0
          puts 'pass' 
        else
          puts 'fail'
        end
      end
    end

    private

    include Enumerable

    attr_accessor :slide_dir

    def initialize(manifest, slide_dir)
      @slides = manifest['slides']
      @slide_dir = slide_dir
    end

    def each
      @slides.each.with_index do |page, i|
        slide = Slide.new(page, File.read(File.join(slide_dir, page['file'])), i)
        yield slide
      end
    end

    def slide_markup
      <<~HTML
        <section data-markdown>
          <script type="text/template">
            #{yield}
          </script>
        </section> 
      HTML
    end
  end

  class Slide
    attr_reader :content, :test, :position
    def initialize(slide, content, position)
      @content = content
      @test = slide['test']
      @position = position
    end
  end
end
