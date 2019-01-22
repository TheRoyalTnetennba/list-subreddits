require "securerandom"
require "pry"
require "json"
require "redd"
require_relative "scraper.rb"


if __FILE__ == $PROGRAM_NAME

  require "optparse"

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: bundle exec main.rb [options]"

    opts.on("-d", "--direction [DIRECTION]", "Down to go from newest subreddit to oldest, up to go oldest to newest. "\
      "Must be either 'up' or 'down'. Defaults to 'down'.") do |direction|
      options[:direction] = direction.downcase.to_sym
    end
    opts.on("-a", "--user_agent [USER_AGENT]", "User agent to use for making requests. Leave blank for random.") do |user_agent|
      options[:user_agent] = user_agent
    end
    opts.on("-c", "--client_id [CLIENT_ID]", "Client ID to use for making requests. Will default to ENV['REDDIT_CLIENT'] if available.") do |client_id|
      options[:client_id] = client_id
    end
    opts.on("-s", "--secret [SECRET]", "Secret to use for making requests. Will default to ENV['REDDIT_SECRET'] if available.") do |secret|
      options[:secret] = secret
    end
    opts.on("-u", "--username [USERNAME]", "Username to use for making requests. Will default to ENV['REDDIT_USERNAME'] if available.") do |username|
      options[:username] = username
    end
    opts.on("-p", "--password [PASSWORD]", "Password to use for making requests. Will default to ENV['REDDIT_PASSWORD'] if available.") do |password|
      options[:password] = password
    end
    opts.on("-i", "--interval [SAVE_INTERVAL]", Integer, "Save data to output file every x number of subreddits. Defaults to 1000.") do |interval|
      options[:save_interval] = save_interval
    end
    opts.on("-o", "--output_file [OUTPUT_FILE]", "File to save subreddit data to. Will default to ENV['LIST_SUBREDDITS_OUTPUT'] if available."\
      " Otherwise defaults to ./subreddit_data.json") do |output_file|
      options[:output_file] = output_file
    end
  end.parse!
  scraper = Scraper.new options
end

