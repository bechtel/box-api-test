%w(rubygems sinatra rest-client json).each { |lib| require lib }

API_KEY = ""

# LOCALHOST
enable :sessions

get '/' do
  erb :index, :layout => :application
end

get '/login' do
  
  require "nokogiri"
  
  # Box oauth docs: http://developers.box.com/get-started/#authenticating
  # Create a Box App: https://bechtel.box.com/developers/services
  @boxauth = "https://www.box.com/api/1.0/rest?action=get_ticket&api_key=#{API_KEY}"  

  # Call the URL above and interrogate response
  response = RestClient.get @boxauth
  puts "BODY:" + response.body
  doc = Nokogiri::XML(response.body)

  # Parse XML response to get the ticket value
  # <response><status>get_ticket_ok</status><ticket>gjbnz...g0gzfi</ticket></response>
  ticket = doc.xpath('//response/ticket').inner_text
  
  redirect "https://www.box.com/api/1.0/auth/" + ticket
  
end

get "/callback" do
  
  
  session["token"] = params[:auth_token]
  session["ticket"] = params[:ticket]
  
  redirect "/"
    
end

get "/explorer" do
  erb :explorer, :layout => :application
end

get "/callapi" do
  
  # curl https://www.box.com/api/2.0/users -H "Authorization: BoxAuth api_key=blah&auth_token=blah2"
  
  @uri = "https://www.box.com/api/2.0" + params["api"]

  begin
    @jdata = JSON.parse(RestClient.get @uri, :Authorization => "BoxAuth api_key=#{API_KEY}&auth_token=" + session["token"]  )
  rescue
    @jdata = "no results"
  end
  
  puts @uri
  puts @jdata
  @jdata.to_s

end

get "/logout" do
  
  session["token"] = nil
  
  redirect "/"
  
end






