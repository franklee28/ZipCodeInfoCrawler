#!/usr/bin/ruby

#Object to store the result
class ResultObject
  attr_accessor :postalCode, :city, :state, :population, :database
  
  def initialize(postalCode, city, state, population = 0, database = false)
    @postalCode = postalCode
    @city = city
    @state = state
    @population = population
    @database = database  #Flag to determine whether this result has already been in the database or not
  end
end