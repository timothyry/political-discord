require_relative '../helpers/replacements.rb'
require_relative'../helpers/handles.rb'
require 'yaml'

class Miner

  attr_accessor :client

  def initialize(celHandles, polHandles, wordHash)
    @posts = []
    @celHandles = celHandles
    @polHandles = polHandles
    @wordHash = wordHash
    output("Miner connecting to Twitter ...\n")
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = 'Ax2NVLgGifTUPqqhDF6eHUsfS'
      config.consumer_secret = 'Oi7VLrBhi8hFQ4ByJfaao8p6pi6xBiN4w1nvGu2L4smTWVPATe'
    end
    output("Success.\n")
  end
  
  def output(out_text)
    puts "#{Time.now.to_s}: #{out_text}"
  end
  
  def loadPosts
    @posts = YAML::load_file(File.join(__dir__, 'posts.yml'))
  end

  def savePosts
    File.open("posts.yml", "w") {|file| file.write(@posts.to_yaml) }
    output "Posts saved to #{file}.yml."
  end
  
  def popPost
    output "Sampling from posts..."
    post = @posts.sample
    @posts -= [post]
    return post
  end
  
  def mine(amount)
    new_posts = []
    if amount < 0
      output("Amount of tweets to mine must be > 0.")
    elsif
      amount > 40
      output("Amount of tweets to mine cannot exceed 40.")
    else
      output("Preparing to mine [#{amount}] tweets.")
      maxAttempts = [3, (amount.to_f*0.25).to_i].max
      amount.times do |current|
        begin
          attempts ||= 1
          output("Mining tweet #{current+1} of #{amount}. (Attempt #{attempts} of #{maxAttempts})")
          new_post = Post.new(@client, @polHandles.sample, @celHandles.sample, @wordHash)
          new_posts << new_post
        rescue Twitter::Error => te
          if attempts <= maxAttempts
            output "Error: Time-out. Sleeping #{5**attempts} seconds before re-attempting mine."
            sleep(5**attempts)
            attempts += 1
            retry
          else
            output "Error: Exceeded timeout attempts."
          end
        end
      end
      if !new_posts.nil? && !@posts.nil?
        new_posts.each do |curr_new_post|
          @posts.each do |curr_master_post|
            new_posts -= [curr_new_post] if curr_new_post.dump[3].to_s == curr_master_post[3]
          end
        end
      end
      @posts = [] if @posts.nil?
      output("Complete. Mined #{new_posts.size} unique tweets.")
      new_posts.each {|new_post| @posts << new_post.dump}
    end
  end
end

class Post
  
  include Twitter::Autolink
  
  def initialize(client, polHandle, celHandle, wordHash)
    @client = client
    print "#{Time.now.to_s}: Mining tweet from #{celHandle} for #{polHandle}.\n"
    @pol = @client.user(polHandle)
    @cel = @client.user(celHandle)
    @tweet = client.user_timeline(@cel, {:count => 100, :exclude_replies => true}).sample
    @tweet_body = @tweet.full_text.dup.force_encoding("utf-8")
    @orig_tweet = @tweet_body.dup
    wordHash.each do |word, replace|
      @tweet_body.gsub!(/\s#{word}\b/i, " #{replace} ")
    end
=begin
@tweet_body.gsub!("’", "'")
    @tweet_body.gsub!("👌", "")
    @tweet_body.gsub!("💯", "")
    @tweet_body.gsub!("‘", "'")
    @tweet_body.gsub!("💜", "")
    @tweet_body.gsub!("“", "\"")
=end
  end
  
  def dump
    return [@cel.name, @pol.name, @pol.profile_image_uri.to_s, @tweet_body, @orig_tweet]
  end
end

class Discord
  
  include Twitter::Autolink
  
  def initialize(orient, celName, polName, pol_image_uri, tweet_body, orig_tweet)
    @orient = orient
    @celName = celName
    @polName = polName
    @pol_image_uri = pol_image_uri
    @tweet_body = tweet_body
    @orig_tweet = orig_tweet
  
    case rand(200)
      when 0..4
        @tweet_body = @tweet_body + " In my opinion, this isn't the kind of America I want to live in."
      when 5..9
        @tweet_body = "There's still work to be done, America. " + @tweet_body
      when 10..14
        @tweet_body = "My opponent... Where to begin? " + @tweet_body + " My opponent is a real danger."
      when 15..19
        @tweet_body = "Here it is: my 20 second speech. " + @tweet_body + " Let's dispel with this notion that I don't know what I'm doing."
      when 20..24
        @tweet_body = @tweet_body + " Sad. Terrible."
      when 25..29
        @tweet_body = "I demand my 10 minutes. " + @tweet_body
      when 30..34
        @tweet_body = "Young people should love me. I love them. A lot. " + @tweet_body
      when 35..39
        @tweet_body = @tweet_body + " And, I'd like to add that I choked the enemy to death, watching the lights in his eyes dim to a freedom-filled darkness. Thank you."
      when 40..44
        @tweet_body = "And let me be clear: " + @tweet_body
      when 45..49
        @tweet_body = "Friends call me up all the time and they say, \"#{@polName}, " + @tweet_body + ".\" Super. Absolutely super."
      when 50...54
        @tweet_body = @tweet_body + " Please clap."
      when 55..59
        @tweet_body = "China... Where to begin with China. " + @tweet_body + " Bad deal."
      when 60..64
        @tweet_body = "This you should vote me. " +@tweet_body + " Thank you, thank you. Taxes, they'll be lower... son."
      when 65..69
        @tweet_body = "I will not hurt or harm you. " + @tweet_body + " It was a good bill, and I liked it. You know how hard it is to find a bill you like."
      when 70..74
        @tweet_body = @tweet_body + " Let's go get a drink and have a cigarette."
      when 75..79
        @tweet_body = "Another Latin word, status quo, and it stands for, \"Man, the middle-class everyday Americans are really gettin' taken for a ride.\" " + @tweet_body
      when 80..84
        @tweet_body = "It's time for a political revolution. " + @tweet_body
      when 85..89
        @tweet_body = "Savage. Blood coming out of her eyes. " + @tweet_body + " Blood coming out of... where ever."
      when 90..94
        @tweet_body = "It's past time we buried this divisive rhetoric. " + @tweet_body + " Also, my opponent wants to murder the U.S. in its sleep."
      when 95
        @tweet_body = @tweet_body + " Fuck it. We'll do it live."
      when 96
        @tweet_body = "My fellow countrymen, " + @tweet_body
      when 97
        @tweet_body = @tweet_body + " We're going to clean up America, like with a cloth."
      when 98
        @tweet_body = "Ask not '" + @tweet_body + "'; Ask 'when is it my turn to speak? I've been waiting.'"
      when 99
        @tweet_body = @tweet_body + " Actually, nevermind. We're screwed."
      when 100..104
        @tweet_body = @polName + " regrets nothing and " + @tweet_body
      when 105..109
        @tweet_body = "I have a lot of dogs. " + @tweet_body + " All of this to say I also own a lot of dog whistles."
      when 110..114
        @tweet_body = @tweet_body + " And to my opponent, why don't you purify yourself in the waters of Lake Minnetonka?"
      when 115
        @tweet_body = "I've made a lot of mistakes. " + @tweet_body + " ... Yeah, you could say I've really fucked up. Sorry 'bout it."
      when 116..119
        @tweet_body = "What do you have to lose by voting for me? " + @tweet_body + " I mean hell, give it a shot you know?"
      when 120..124
        @tweet_body = "Corporate donations? Schmorprate donations! I say " + @tweet_body + " That'll show 'em."
      when 125..129
        @tweet_body = @tweet_body + " That's why I support the 2nd Amendment. Bury me with my gun, fellow Americans."
      when 130..134
        @tweet_body = "Social media? Not in my America. Capitalist media is our God-given right. And " + @tweet_body + " Amen."
      when 135..139
        @tweet_body = "The U.S. is the greatest country ever seen, but " + @tweet_body + " would go a long way to making us even greater!"
      when 140
        @tweet_body = "It was the best of times, it was the " + @tweet_body + " of times. God bless this country."
      when 141
        @tweet_body = @tweet_body + " We owe it to democracy."
      when 142
        @tweet_body = "National security is being undermined. Deleted emails from my opponent said \"" + @tweet_body + "\" Sad."
      when 143
        @tweet_body = "Americans deserve 2 things. (1) Lower Taxes. (2a) " + @tweet_body + " And maybe (2b) the American Dream. #2bl3ss3d2Bstr3ss3d"
      when 144
        @tweet_body = "The political system is broken. " + @tweet_body + " is not an American way to govern."
      when 145..149
        @tweet_body = "The main stream media keeps reporting lies. \"" + @tweet_body + "\" is a load of BUPKISS!"
      when 150..154
        @tweet_body = "Strap on your big boy pants and read my lips: " + @tweet_body + " BooYAH!"
      when 155..159
        @tweet_body = @tweet_body + " And that's the bottom line."
      when 160..164
        @tweet_body = @tweet_body + " And I'll continue to cram this legislation down the throats of our patriots, respectfully."
      when 165..169
        @tweet_body = "It's time for those that represent the American people to dangle massive cojones and say: " + @tweet_body
      when 170..174
        @tweet_body = @tweet_body + " Look beneath the floorboards for the secrets I have hid."
      when 175..179
        @tweet_body = "Our country is in trouble. News headlines keep reading " + @tweet_body
      when 180..184
        @tweet_body = @tweet_body + " and I'm getting really, really sick of these amoral athiest liberals destroying America."
      when 185..189
        @tweet_body = "Of course I live in a bubble. Bubbles are comfortable as f**k. Terrific people tell me \"#{polName}, " + @tweet_body + "\""
      when 190..194 
        @tweet_body = "ESPN is a really fantastic channel, folks. True patriots at pretending to do news. Fantastic. " + @tweet_body
      when 195..199
        @tweet_body = "Smells like... fear. " + @tweet_body
    end
    tagList = Handles::HashTags
    firstTag = tagList.sample
    tagList -= [firstTag]
    secondTag = tagList.sample
    @tweet_body = @tweet_body + " " + firstTag if rand(2) == 1  
    @tweet_body = @tweet_body + " " + secondTag if rand(4) == 1
  end

  def draw(client)
    html = ""
    if @orient == "left"
      html << "<div class='tweet_left'>"
      html << "<p class='user_name_left'>#{@polName}</p>"
      html << "<p class='user_image_left'><img height='65px' width='65px' src='#{@pol_image_uri}'></img></p>"
      html << "<div class='tweet_body_left'><div class='celTweet'><i>Original tweet by  </i><u>#{@celName}</u><i>:</i> #{auto_link(@orig_tweet)}</div><div class='polTweet'>#{auto_link(@tweet_body)}</div></div>"
      html << "</div>"    
    elsif @orient == "right"
      html << "<div class='tweet_right'>"
      html << "<p class='user_name_right'>#{@polName}</p>"
      html << "<p class='user_image_right'><img height='65px' width='65px' src='#{@pol_image_uri}'></img></p>"
      html << "<div class='tweet_body_right'><div class='celTweet'><i>Original tweet by  </i><u>#{@celName}</u><i>:</i> #{auto_link(@orig_tweet)}</div><div class='polTweet'>#{auto_link(@tweet_body)}</div></div>"
      html << "</div>"  
    end
    html
  end
end

class WelcomeController < ApplicationController
  include Replacements
  include Handles
  
  def index
    startTime = Time.now

    tweetMiner = Miner.new(CelHandles, PolHandles, WordHash)
    tweetMiner.loadPosts

    currentTweet = tweetMiner.popPost

    firstTweet = Discord.new("left", currentTweet[0], currentTweet[1], currentTweet[2], currentTweet[3], currentTweet[4])

    currentTweet = tweetMiner.popPost

    secondTweet = Discord.new("right", currentTweet[0], currentTweet[1], currentTweet[2], currentTweet[3], currentTweet[4])


    index = File.new(Rails.root + "app/views/welcome/index.html.erb", "w+")
    index.puts("<div align='center'>")
    index.puts("<p id='topbanner'></p>")
    index.puts("<p id='star-bottom'>AMERICA</p><p id='star-top'>FUCK YEAH</p>")
    index.puts("<p id='middlebackground'></p>")
    index.puts("<div class='main'><br>")
    index.puts(firstTweet.draw(tweetMiner.client))
    index.puts("<br><br>")
    index.puts(secondTweet.draw(tweetMiner.client))
    index.puts("</div>")
    index.puts("<p id='bottomborder'><a href='mailto:solomonwurzbach@gmail.com'>solomon wurzbach.</a></p></div>")
    index.close
    print "#{Time.now.to_s}: Finished writing new index.html webpage.\n"
    print "#{Time.now.to_s}: Program took #{Time.now - startTime}s to complete.\n"
  end
end
