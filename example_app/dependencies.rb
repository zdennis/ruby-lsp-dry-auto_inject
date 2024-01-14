require "dry-container"
require "dry-auto_inject"

module App
end

module App
  class MyContainer
    extend Dry::Container::Mixin

    register :foo do
      Foo.new
    end

    register "baz" do
      Foo::Baz
    end

    register "bar" do
      Bar.new
    end

    register "car" do
      Foo::Car.new
    end

    register "cat" do
      Cat
    end

    register "foo.baz" do
      Foo::Baz
    end

    class What
      def foo
      end
    end
  end

  class Huh
  end
end


Import = Dry::AutoInject(App::MyContainer)
