# this gets meta

# make something from several local vars
# page, per_page, order_by, order_type - some local vars
params = ["page", "per_page", "order_by", "order_type"].map do |param|
  param + "=" + binding.local_variable_get(param).to_s
end.join("&")

# make something from method parameters
# same as previous code but in different context
def get_batch(page=1, per_page=30, order_by="created_at", order_type="desc")
    method(__method__).parameters.map do |param|
      param[1].to_s + "=" + binding.local_variable_get(param[1]).to_s
    end.join("&")
    # => page=1&per_page=30&order_by="created_at"&order_type="desc"
end

# somewhat golfy api request
def request(type, id="", params="")
    id = id.to_s
    params = params.to_s
    api_path = case type
      when "orders"
        "/api/v2/orders?"
      when "order_metadata"
        raise "ID required" if id.empty?
        "/api/v2/orders/#{id}?"
      when "shop_metadata"
        raise "ID required" if id.empty?
        "/api/v2/shop/#{id}?"
      end
    api_path.chop! if params.empty?

    response = HTTParty.get(
      @domain + api_path + params, 
      basic_auth: @auth
    )
    response_valid?(response)
    response
end

# calling defined objects
["FirstObj", "SecondObj", "ThirdObj"].each do |obj|
  ans = Object.const_get(obj).where(email: email)
  # ...more operations on ans, maybe loading the result into an array or something
end

# basic proc
expand_fns = ->(args){ args.map { |arg| arg.prepend("add_to_") } }
expand_fns.call(["x", "y"]) # => ["add_to_x", "add_to_y"]     
                                 

# the same as above but lambda
expand_fns = lambda {|fn| fn.prepend("edit_")}
["phone", "name", "email"].map(&expand_fnames) # => ["edit_phone", "edit_name", "edit_email"]

# instead of:
# @name = name, @color = color, @sound = sound you can do:
def initialize(name, color, sound)
  method(__method__).parameters.map do |p|
    instance_variable_set("@" + p[1].to_s, binding.local_variable_get(p[1]))
  end
end

# creating an object from a CSV string
def self.deserialize(s)
  a_obj = nil
  CSV.parse(s, col_sep: ";") do |csv|
    cname = csv[0]
    attrs = csv[1..-1]
    a_obj = Object.const_get(cname).new(*attrs) # <- this splat is important; converts array to object attributes
  end

  a_obj
end

# the whole task, for context:
require 'csv'

module Throat
  attr_accessor :sound

  def speak
    puts @sound
  end

  def initialize(name, color, sound)
    super
  end
end

class Animal
  attr_accessor :name
  attr_accessor :color

  def initialize(name, color, sound = nil)
    method(__method__).parameters.map do |p|
      instance_variable_set("@" + p[1].to_s, binding.local_variable_get(p[1]))
    end
  end

  # This can get overridden by Throat module
  def speak
    "This animal is silent."
  end

end

class Dog < Animal
  include Throat
end

class Cat < Animal
  include Throat
end

class Fox < Animal
  include Throat
end

class Fish < Animal
  # It just doesn't speak.
end

class Dragon < Animal
  include Throat
  attr_accessor :fiery_sfx

  # I suppose no other "animal" can breathe fire
  def breathe_fire
    puts @fiery_sfx
  end
end

class AnimalSerializer
  def self.serialize(a_obj)
    s = [].append(a_obj.class.to_s)
    s << %w(name color sound).map do |attr|
      a_obj.send(attr)
    end
    s.join(";")
  end
  
  def self.deserialize(s)
    a_obj = nil
    CSV.parse(s, col_sep: ";") do |csv|
      cname = csv[0]
      attrs = csv[1..-1]
      a_obj = Object.const_get(cname).new(*attrs)
    end

    a_obj
  end
end

fdg = Dog.new("Foxtrot dog", "black", "woof")
ldg = Dog.new("Long dog", "black", "wan wan")
cblini = Cat.new("kot blini", "ruby", "give me blini, human")
xof = Fox.new("xoF", "crystal", "...")
fsh = Fish.new("Nemo", "red")

dragon = Dragon.new("DRAK", "red", "ROAR")
dragon.fiery_sfx = "GAOOOOOO!!!11"

AnimalSerializer.serialize(dragon)
AnimalSerializer.deserialize("Dragon;Drak;red;ROAR")
AnimalSerializer.deserialize("Cat;Maine coon;Ecru;Meow.")