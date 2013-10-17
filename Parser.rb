#!/usr/bin/ruby

class Parser
  
  #Parse the USPS result to get the city and the state
  def usps_parse(content)
    #Check the postal code is valid or not
    result = /<p\s*class=\"noResult\">/.match(content)
    #invalid
    if result != nil
      #puts "Not Valid Postal Code"
      "Not Valid Postal Code"
    #valid
    else
      location = /preferred<\/u>\s*city\s*in\s*<span\s*class=\"zip\">\d{5}<\/span>[^>]*?>\s*?<p class=\"std-address\">(.*?)\s*?([A-Z]{2})<\/p>/.match(content)
      if location != nil
        city = location[1]
        state = location[2]
        [city, state]
      else
        "No Content Returned"
      end
    end
  end
  
  #Parse the Wiki result to get the population
  def wiki_parse(content)
    #City which has a population based on United States Census
    population = /Population[[^>]*?>]+?<\/tr>\s*<tr class="mergedrow">[[^>]*?>]+?<td>([\d|,]*)[^\d|^,]/.match(content)
    
    if population != nil
      #puts population
      popu = population[1].delete(',')
      popu
    else
      #In most case, the wiki page displays the data from census in a table.
      #However, in some case, some cities, e.g Hollywood, do not provide the data table.
      #Therefore, the program tries to retrive the population in the content by searching keyowrd 'population' and the number followed.
      population = /[Pp]opulation[^<|^>]*?([\d|,]+)/.match(content)
      #puts "2"
      #puts population[1]
      if population != nil
        popu = population[1].delete(',')
        popu
      else
        popu = nil
        popu
      end
    end
  end
end