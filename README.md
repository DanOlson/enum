# Noomer

A basic enum implementation for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'noomer'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install noomer

## Usage

Define a PORO to hold your variants, and include the `Noomer` module. This provides an `enum` method you can use to declare your enum variants.

```ruby
class Color
  include Noomer

  # Declare your variants with the `enum` method
  Red = enum
  Green = enum
  Blue = enum
end
```

The `enum` method returns a subclass of the including class. In the above example, it returns a subclass of `Color`. When the result of the `enum` method is assigned to a constant, a method named after the constant is defined which returns an instance of the new subclass. In the above example, `enum` is invoked three times, each one creating a new subclass of `Color`. Three methods are defined, each one returning an instance of the corresponding subclass:

```ruby
Color::Red()
# => #<Color::Red 0x000000010a27ccb0 @value=nil>

Color::Green()
# => #<Color::Green:0x000000010d146b40 @value=nil>

Color::Blue()
# => #<Color::Blue:0x000000010d26c600 @value=nil>
```

These methods can be invoked repeatedly, and will always return the same instance.

Now we have three new classes, and three new methods:

| Class          | Method           |
|----------------|------------------|
| `Color::Red`   | `Color::Red()`   |
| `Color::Green` | `Color::Green()` |
| `Color::Blue`  | `Color::Blue()`  |

`Color::Red()` returns an instance of `Color::Red`, which `is_a?` `Color`.

### Associated Data

`Enum` also supports declaring variants with associated data:

```ruby
class Book
  attr_reader :title

  def initialize(title) = @title = title
end

class Subject
  include Noomer

  Math = enum(Book)
  Literature = enum(Book)
  Science = enum(Book)
  PhyEd = enum
end
```

Here we have a `Subject` class that includes `Enum`, and four variants are declared; three of which require a book and one that does not. When `enum` is called with an argument that is a `Class`, the accompanying constructor method requires an argument that is an instance of that class. In the above example:

```ruby
math_book = Book.new('Beyond Algebra')
# => #<Book:0x000000010d145f88 @title="Beyond Algebra">
math = Subject::Math(math_book)
# => #<Subject::Math:0x000000010d1a8bb0 @value=#<Book:0x000000010d145f88 @title="Beyond Algebra">>
math.value == math_book
# => true
```

If you provide an argument that is not an instance of `Book`, you'll get an error:

```ruby
Pencil = Struct.new(:number)
pencil = Pencil.new(2)
Subject::Math(pencil)
# => ArgumentError
```

Enum classes works well with `case` statements. Using the example above:

```ruby
# @param subject [Subject]
# @return [void]
def study(subject)
  case subject
  when Subject::Math, Subject::Literature, Subject::Science
    book = subject.value
    book.open_to_chapter(assignment.chapter)
    read(book)
  when Subject::PhyEd
    stretch
    jog
    pushups
  end
end
```

### Explicit Discriminators

Variants with can be declared with explicit discriminators. A variation on the `Color` example above:

```ruby
class Color
  include Noomer

  Red = enum('#ff0000')
  Green = enum('#00ff00')
  Blue = enum('#0000ff')
end
```

When instantiated, the value of each variant is that of the provided discriminator:

```ruby
red = Color::Red()
green = Color::Green()
blue = Color::Blue()
red.value
# => "#ff0000"
green.value
# => "#00ff00"
blue.value
# => "#0000ff"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### TODOs

- Support Ruby versions < 3.2

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DanOlson/noomer.
