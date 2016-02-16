require 'rubygems'
require 'bundler'
require 'yaml'
Bundler.require(:default)
@properties = YAML.load(File.read("./properties.yml"))

@item_list = []

class Item
  attr_accessor :price, :name, :length, :quantity, :weight

  def price=(number)
    @price = number.round(2)
  end

  def weight=(number)
    @weight = number.round(1)
  rescue
    @weight = 0
  end
end

def add_simple_item(name)
  object = @properties[name]
  object["quantity"].times do
    item = Item.new
    item.price = object["price"]
    item.name = name
    item.weight = object["weight"]
    @item_list << item
  end
end

add_simple_item("castor")
add_simple_item("three_socket_tee")
add_simple_item("single_socket_tee")
add_simple_item("extra_heavy_flange")



def weight_of_pipe_by(length)
  unit_weight = @properties["pipe"]["weight"]
  (length/12) * unit_weight
end

def price_of_pipe_by(length)
  unit_price = @properties["pipe"]["price"]
  (length/12) * unit_price
end

def add_pipe_item(name, length)
  object = @properties[name]
  object["quantity"].times do
    item        = Item.new
    item.price  = price_of_pipe_by(length)
    item.weight = weight_of_pipe_by(length)
    item.length = "#{length}\""
    item.name   = "#{name} pipe"
    @item_list << item
  end
end

def calculate_leg_length
  goal_height         = @properties["table"]["height"]
  block_depth         = @properties["block"]["depth"]
  added_castor_height = @properties["castor"]["wheel_and_joint_height"]
  goal_height - (block_depth + added_castor_height)
end

# How much we need to account for a flange to a tee joint
# connection.
def flange_offset
  flange_base_diameter = @properties["extra_heavy_flange"]["diameter"]
  pipe_diameter = @properties["pipe"]["outside_diameter"]
  (flange_base_diameter/2) + (pipe_diameter/2)
end

def calculate_shelf_support_length
  goal_width          = @properties["table"]["width"]
  bleed               = @properties["table"]["bleed"] * 2
  goal_width - ((flange_offset * 2) + bleed)
end

def calculate_short_crosspiece_length
  goal_length          = @properties["table"]["length"]
  bleed                = @properties["table"]["bleed"] * 2
  goal_length - ((flange_offset * 2) + bleed)
end

add_pipe_item("leg", calculate_leg_length)
add_pipe_item("shelf_support", calculate_shelf_support_length)
add_pipe_item("short_crosspiece", calculate_short_crosspiece_length)

tp @item_list

def sum(column)
  prices = @item_list.map {|item| item.send(column)}
  prices.inject(0, :+)
end

puts "Total cost: $#{sum("price").round(2)}"
puts "Total weight of frame: #{sum("weight").round(1)} lbs"
