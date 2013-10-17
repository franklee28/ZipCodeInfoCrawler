#!/usr/bin/ruby

require './ResultObject'
require './HttpRequest'
require 'mysql'

class Crawler
  attr_accessor :postals, :results, :http
  
  def initialize()
    #@postals = []
    @results = []
    @http = HttpRequest.new
  end

  def get_postal_info()
    
    #Iterate the postal code and retrive the info for each postal code
    #postals.each do |postal|
    for code in 00000..99999
      #Sleep Time between every request to avoid the heavy traffic to the server
      sleep 10
      
      #Establish a 5-digit code
      postal = (code.to_s).rjust(5, '0')
      puts postal
      #Look up the postal code in the databse first
      begin
        con = Mysql.new 'localhost', 'user1', 'user1', 'postalcode'
        rs = con.query("select * from postal_map where Zip = " + postal)
  
      rescue Mysql::Error => e
        puts e.errno
        puts e.error
  
      ensure
        con.close if con
      end
      #if so, directly read the info from the database
      if rs.num_rows > 0
        #puts "database"
        rs.each_hash do |row|
          result = ResultObject.new(postal, row['City'], row['State'], row['Population'].to_s, true)
          results << result
        end
      #if not, retrive the info by using usps api
      else
        #puts "crawl"
        info = http.fetch(postal)
      
        if info != "Not Valid Postal Code" && info != "No Content Returned"
          result = ResultObject.new(postal, info[0], info[1], info[2])
          #Store the result
          results << result
        elsif info == "No Content Returned"
          puts postal + " request is temperorily denied by USPS"
        else
          puts postal + " is not a valid postal code according to USPS"
        end
      end
    end
    
    #Output
    output
  end
  
  def output()
    if results.length > 0 then
      con = Mysql.new 'localhost', 'user1', 'user1', 'postalcode'
      pst = con.prepare "insert into postal_map(Zip, City, State, Population) values (?, ?, ?, ?)"
      
      puts "ZIP\t\t|CITY\t\t|STATE\t\t|POPULATION"
      results.each do |result|
        puts "#{result.postalCode.to_s}\t\t|#{result.city}\t\t|#{result.state}\t\t|#{result.population.to_s}"
        pst.execute result.postalCode.to_s, result.city, result.state, result.population.to_s unless result.database
      end
    end
  rescue Mysql::Error => e
    puts e.errno
    puts e.error

  ensure
    con.close if con
    pst.close if pst
  end
end

#Database connection test block
=begin
begin
  con = Mysql.new 'localhost', 'user1', 'user1'
  puts con.get_server_info
  rs = con.query 'SELECT VERSION()'
  puts rs.fetch_row   
  
rescue Mysql::Error => e
  puts e.errno
  puts e.error
  
ensure
  con.close if con

end
=end

#Crawler start
crawler = Crawler.new
crawler.get_postal_info()