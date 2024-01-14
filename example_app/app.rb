require "bundler/setup"
require "dry-auto_inject"

require_relative "dependencies"
Dir["./models/**/*.rb"].each { |f| require f }

foo = MyContainer["foo"]

puts foo.call


# Foo.foo

# Foo

# foo = Foo.new
# foo.foo

# Bar.bar

bar = Bar.new
bar.bar

baz = abc
baz.call

car = foo_car_something
car.something



# Cat.cat

# self.cat

# cat = Cat.new
# cat.cat

# YAML.load_file(".index.yml.bak")
