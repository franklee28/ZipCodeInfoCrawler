#!/usr/bin/ruby

require 'net/http'
require 'openssl'
require './Parser'

class HttpRequest
  
  #USPS API
  def create_usps_url(postal)
    #url = URI.parse('https://tools.usps.com/go/ZipLookupResultsAction!input.action?resultMode=2&companyName=&address1=&address2=&city=&state=Select&urbanCode=&postalCode=' + postal.to_s + '&zip=')

    url = URI('https://tools.usps.com/go/ZipLookupResultsAction!input.action')
    params = { :resultMode => 2, :companyName => nil, :address1 => nil, :address2 => nil, :city => nil, :state => "Select", :urbanCode => nil,:postalCode => postal, :zip => nil }
    url.query = URI.encode_www_form(params)
    url
  end
  
  #WIKI API
  def create_wiki_url(city, state)
    url = URI('http://en.wikipedia.org')
    @newCityWord = []
    #Process the city phrase
    #Capitalize every word of the city and replace the space to "_"
    @cityWord = city.split(/\s+/)
    @cityWord.each { |word| @newCityWord << (word.downcase).capitalize}
    #Reconstruct the city phrase
    city = @newCityWord.join("_")
    #Process the path so that the query can direct to the desired page
    url.path = "/wiki/" + city + ",_" + state
    url
  end
  
  #Fetch the USPS result page by using https
  def fetch_usps(url)
    #puts url

    @http = Net::HTTP.new(url.host, url.port)
    #Enable SSL
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE  #Should change to VERIFY_PEER and use cert file for security purpose
    uspsRequest = Net::HTTP::Get.new(url)
    uspsResponse = @http.request(uspsRequest)

    uspsResponse.body if uspsResponse.is_a?(Net::HTTPSuccess)
  end
  
  #Fetch the Wiki result page
  def fetch_wiki(url)
    #puts url
    
    @http = Net::HTTP.new(url.host, url.port)
    wikiRequest = Net::HTTP::Get.new(url)
    wikiResponse = @http.request(wikiRequest)
    
    #In case that Wikipedia will redirect the search result to a stored page
    case wikiResponse
    when Net::HTTPSuccess then
      wikiResponse.body
    when Net::HTTPRedirection then
      location = wikiReponse['location']
      warn "Redirect to #{location}"
      fetch_wiki(URI(location))
    else
      wikiResponse.value
    end
  end
  
  #Fetch the city, state and population based on the postal code
  def fetch(postal)
    p = Parser.new
    uspsUrl = create_usps_url(postal)
    uspsContent = fetch_usps(uspsUrl)
    result = p.usps_parse(uspsContent) unless uspsContent == nil
    result = "No Content Returned" if uspsContent == nil
    #puts result
    if result != "Not Valid Postal Code" && result != "No Content Returned"
      wikiUrl = create_wiki_url(result[0], result[1])
      wikiContent = fetch_wiki(wikiUrl)
      population = p.wiki_parse(wikiContent)
      [result[0], result[1], population]
    elsif result == "No Content Returned"
      result
    else
      result
    end
  end
end
=begin
#Function test part
h = HttpRequest.new
p = Parser.new
#puts h.fetch_usps(h.create_usps_url(90007))
puts p.usps_parse(h.fetch_usps(h.create_usps_url(55555)))
#puts h.fetch_wiki(h.create_wiki_url("Los Angeles", "CA"))
p.wiki_parse(h.fetch_wiki(h.create_wiki_url("Hollywood", "CA")))
=end