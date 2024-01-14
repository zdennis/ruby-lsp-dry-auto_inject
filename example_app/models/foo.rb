class Foo
  include Import["bar"]

  def call
    bar.call
    puts "#{self.class} has injected bar=#{bar.inspect}"
  end
end
