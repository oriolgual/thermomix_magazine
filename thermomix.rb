require "open-uri"
require "fileutils"

class Magazine
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def to_pdf(destination)
    FileUtils.mkdir_p(path)
    image = 1

    loop do
      begin
        file = image.to_s.rjust(3, '0') + '.jpg'
        puts "Downloading #{file}..."
        File.write(path + file, open(url + file).read, {mode: 'wb'})
        image += 1
      rescue OpenURI::HTTPError
        break
      end
    end

    puts "Ended downlaoding pages, building PDF..."

    jpg_to_pdf(destination)

    puts "PDF successfully built at #{destination}/#{id}.pdf"

    FileUtils.rm_rf(path)
  end

  def jpg_to_pdf(destination)
    files = Dir[path + "*.jpg"].join(' ')
    system("convert #{files} #{destination}/#{id}.pdf")
  end

  def path
    "/tmp/thermomix/#{id}/"
  end

  def url
    "http://www.thermomixmagazine.com/img/revistas/#{id}/zoom/"
  end

  class PDFBuilder
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def build
      system("convert #{files} #{destination}/#{id}.pdf")
    end

    def files
      @files ||= Dir[path + "*.jpg"].join(' ')
    end
  end
end

Magazine.new(ARGV[0]).to_pdf(ARGV[1])
# Magazine.new('5239d19ec4e71').to_pdf('/Users/oriol/Desktop')
# http://www.thermomixmagazine.com/img/revistas/5239d19ec4e71/zoom/006.jpg