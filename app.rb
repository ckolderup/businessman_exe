require 'tempfile'
require 'twitter'
require 'optparse'

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

def computer_company
  company_front = %w[Elec Inter Macro Globo Hyper Infra]
  company_back = %w[tron node trode soft systems ]
  "#{company_front.sample}#{company_back.sample}"
end

def named_firm
  "#{@surnames.sample.chomp} & #{@surnames.sample.chomp}"
end

def dumb
  first = %w[Global Syndicated Amalgamated Professional International Distributed]
  last = %w[Meats Futures Industries Metals Investments Logging Infrastructure Instruction Development Research Systems]
  designator = %w[Inc Corp LLC]
  "#{first.sample} #{last.sample} #{designator.sample}"
end

def acronym
  acro = (1..4).reduce("") {|i| i << ('A'..'Z').to_a.sample}
  acro[2] = '&'
  acro
end

def image
  file = Tempfile.new('bizman')
  file.write(`curl -s "http://www.avatarpro.biz/avatar?s=500" | curl -s -F file=@- cga.graphics/api/convert/`)
  file.rewind
  file
end

company = %w[named_firm computer_company dumb acronym]

length = 141
while length > 140 do
    out = "#{@firsts.sample.chomp} "
    out << "#{@surnames.sample.chomp}, "
    out << "#{@ranks.sample.chomp} "
    out << "#{@departments.sample.chomp} "
    out << @titles.sample.chomp
    out << " at #{send(company.sample)}"
    length = out.length
end


if options[:tweet] then
    client = Twitter::REST::Client.new do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_SECRET']
    end
    client.update_with_media(out, image)
else
    puts out
end
