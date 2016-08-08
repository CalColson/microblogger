require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
	attr_reader :client

	def initialize
		puts 'Initializing MicroBlogger'
		@client = JumpstartAuth.twitter
	end

	def followers_list
		screen_names = []
		@client.followers.each {|f| screen_names << @client.user(f).screen_name}

		screen_names
	end

	def shorten(original_url)
		puts "Shortening this URL: #{original_url}"

		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')

		bitly.shorten(original_url).short_url
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts 'tweet is too long (>140 chars)'
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this dm:"
		puts message

		message = "d @#{target} #{message}"
		screen_names = @client.followers.collect {|f| @client.user(f).screen_name}
		if screen_names.include?(target) 
			tweet(message) 
		else
			puts 'ERROR!: Can only dm followers'
		end
	end

	def spam_followers(message)
		followers = followers_list
		followers.each do |f|
			dm(f, message)
		end
	end

	def friends_last_tweets
		friends = @client.friends
		friends.each do |friend|
			user = @client.user(friend)
			print "#{user.screen_name}: #{user.status.text}"
			puts
		end
	end

	def run
		puts "welcome to the twitter client"
		command = ''
		until command == 'q'
			printf "enter command: "
			input = gets.chomp
			parts = input.split(' ')
			command = parts[0]

			case command
			when 'q' then puts 'Goodbye!'
			when 't' then tweet(parts[1..-1].join(' '))
			when 'dm' then dm(parts[1], parts[2..-1].join(' '))
			when 'spam' then spam_followers(parts[1..-1].join ' ')
			when 'flt' then friends_last_tweets
			when 's' then puts shorten(parts[1])
			when 'turl' then tweet(parts[1..-2].join(' ') + ' ' + shorten(parts[-1]))
			else
				puts "Sorry I don't know what '#{command}' means"					
			end
		end
	end
end


blogger = MicroBlogger.new
blogger.run