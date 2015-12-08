require 'tempfile'
require 'twitter'
require 'optparse'
require 'RMagick'
require 'dotenv'
include Magick

Dotenv.load

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [options]"

    opts.on("-t", "--tweet", "Tweet instead of printing") do |t|
        options[:tweet] = true
    end
end.parse!

@firsts = File.readlines("first.txt")
@surnames = File.readlines("surname.txt")
@ranks = File.readlines("rank.txt")
@departments = File.readlines("department.txt")
@titles = File.readlines("title.txt")

@wintry = %w{Elf Reindeer Santa Claus Kringle Candycane Sleigh Present
  Winter Fireplace Chocolate Stocking Gift Cocoa Boots Bells Mistletoe
  Caroler Chestnut Tree Coal Eggnog Frosty Gingerbread Jinglebell
  Krampus Mittens Noel Nutcracker Partridge Poinsettia Scrooge Sled
  Snowball Snowflake Snowman Sugarplum Yuletide}

def first_name
  if rand(1..100) >= 97
    @wintry.sample
  else
    @firsts.sample.chomp
  end
end

def surname
  if rand(1..100) >= 25
    @wintry.sample
  else
    @surnames.sample.chomp
  end
end

def computer_company
  company_front = %w[Elec Inter Macro Globo Hyper Infra] + @wintry
  company_back = %w[tron node trode soft systems ]
  "#{company_front.sample}#{company_back.sample}"
end

def named_firm
  "#{surname} & #{surname}"
end

def dumb
  first = %w[Global Syndicated Amalgamated Professional International Distributed]
  last = %w[Meats Futures Industries Metals Investments Logging Infrastructure Instruction Development Research Systems] + @wintry
  designator = %w[Inc Corp LLC]
  "#{first.sample} #{last.sample} #{designator.sample}"
end

def acronym
  acro = (1..4).reduce("") {|i| i << ('A'..'Z').to_a.sample}
  acro[2] = '&'
  acro
end

def image(name, title, company)
  file = Tempfile.new('bizman')
  file.write(`curl -s "http://www.avatarpro.biz/avatar?s=500" | curl -s -F file=@- cga.graphics/api/convert/`)
  file.rewind
  bin = File.open(file,'r'){ |f| f.read }
  image = Image.from_blob(bin).first

  image = image.opaque('#55FFFF', 'LimeGreen')
  image = image.opaque('#FF55FF', 'red')

  append = Image.new(750, 500) do
    self.background_color = 'black'
  end

  draw = Draw.new

  text_width = 550
  text_height = 50
  text_margin = 15
  name_y = 260
  title_y = 400
  company_y = 475

  draw.annotate(append, text_width, text_height, text_margin, name_y, name) do
    self.font = './scumm.ttf'
    self.pointsize = 56
    self.fill = 'white'
    self.text_antialias = true
    self.stroke_width = 2
    self.font_weight = 900
  end

  draw.annotate(append, text_width, text_height, text_margin, title_y, title) do
    self.font = './scumm.ttf'
    self.pointsize = 24
    self.fill = 'white'
    self.text_antialias = true
    self.stroke_width = 2
  end

  draw.annotate(append, text_width, text_height, text_margin, company_y, company) do
    self.font = './scumm.ttf'
    self.pointsize = 48
    self.fill = 'white'
    self.text_antialias = true
    self.stroke_width = 2
  end

  combined = (ImageList.new << image << append).append(false)

  file.write(combined.to_blob)
  file.rewind
  file
end

company = %w[named_firm computer_company dumb] #acronym]

@name = nil
@title = nil
@company = nil
length = 141
while length > 140 do
    @name = "#{first_name} #{surname}"
    @title = "#{@ranks.sample.chomp} #{@departments.sample.chomp} #{@titles.sample.chomp}"
    @company = "#{send(company.sample)}"
    out = "#{@name}, #{@title} at #{@company}"
    length = out.length
end

rendered = image(@name, @title, @company)

if options[:tweet] then
    client = Twitter::REST::Client.new do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_SECRET']
    end
    client.update_with_media(out, rendered)
else
    puts out
    `cp #{rendered.path} bizman.png`
end
