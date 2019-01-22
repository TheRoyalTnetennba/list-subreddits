class Scraper


	def initialize opts = {}
		setup opts
	end

	def scrape opts
		url = get_url next_sub
		response = session.client.get url
		next_sub = response.body[:data][(direction == :down ? :after : :before)]
		data = process_response response, data
		save_data data
	end
	

	def save_data
		File.open @output_file, "w" do |f|
			f.write @data.to_json
		end
	end
	
	def load_data
		if File.file? @output_file
			File.open @output_file, "r" do |f|
				@data = JSON.parse(f.read)
			end
		end
	end
	
	def update_newest child = nil
		if child
			@newest = child if @data[child]["created_utc"] > @data[@newest]["created_utc"]
		else
			newest_time = 0.0
			@data.each do |name, entry|
				if newest_time < entry["created_utc"]
					newest_time = entry["created_utc"]
					@newest = name
				end
			end
		end
		@newest
	end
	
	def update_oldest child = nil
		if child
			@oldest = child if @data[child]["created_utc"] < @data[@oldest]["created_utc"]
		else
			oldest_time = 99999999999999999.0
			data.each do |name, entry|
				if oldest_time > entry["created_utc"]
					oldest_time = entry["created_utc"]
					@oldest = name
				end
			end
		end
		@oldest
	end

	def update_url
		@url = "https://oauth.reddit.com/subreddits/new/.json?limit=100"
		if @direction == :down
			@url += "&after=#{@next_sub}" unless @next_sub.nil?
		else
			@url += "&before=#{@next_sub}" unless @next_sub.nil?
		end
	end

	def process_response response
		response.body[:data][:children].each do |child|
			child_data = {}
			child_id = child[:data][:name]
			key_list.each { |key| child_data[key] = child[:data][key.to_sym] }
			@data[child_id] = child_data
			update_newest child_id
			update_oldest child_id
		end
	end

	def key_list
		[
			"public_description",
			"display_name",
			"title",
			"over18",
			"description",
			"subscribers",
			"lang",
			"created_utc",
			"subreddit_type",
			"submission_type"
		]
	end

	def finished?
		if @direction == :down
			
		end
	end


	private
	def setup opts
		opts = set_default_opts opts
		validate_opts opts
		set_instance_vars opts
		load_data
		@next_sub = update_oldest if @direction == :down
		@next_sub = update_newest if @direction == :up
	end

	def set_instance_vars opts
		@direction     = opts[:direction]
		@user_agent    = opts[:user_agent]
		@client_id     = opts[:client_id]
		@secret        = opts[:secret]
		@username      = opts[:username]
		@password      = opts[:password]
		@save_interval = opts[:save_interval]
		@output_file   = opts[:output_file]
		@session       = get_session
		@data          = {}
		@newest        = nil
		@oldest        = nil
		@url           = nil
		@progress      = 0
		@next_sub      = nil
	end

	def set_default_opts opts
		opts[:direction]     ||= :down || :err
		opts[:user_agent]    ||= "#{SecureRandom.hex 20}" || :err
		opts[:client_id]     ||= ENV["REDDIT_CLIENT"] || :err
		opts[:secret]        ||= ENV["REDDIT_SECRET"] || :err
		opts[:username]      ||= ENV["REDDIT_USERNAME"] || :err
		opts[:password]      ||= ENV["REDDIT_PASSWORD"] || :err
		opts[:save_interval] ||= 1000 || :err
		opts[:output_file]   ||= ENV["LIST_SUBREDDITS_OUTPUT"] || "subreddit_data.json" || :err
		validate_opts opts
		opts
	end

	def validate_opts opts
		opts.each do |k, v|
			if v == :err
				raise ArgumentError.new "Missing required setting: #{v}. Try `bundle exec main.rb --help` for more details."
			end
		end
		if ![:up, :down].include? opts[:direction]
			raise ArgumentError.new "Direction must be either 'up' or 'down'."
		end
	end

	def get_session
		Redd.it(
			user_agent: @user_agent,
			client_id:  @client_id,
			secret:     @secret,  
			username:   @username,
			password:   @password
		)
	end
end