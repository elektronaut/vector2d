[![Version](https://img.shields.io/gem/v/vector2d.svg?style=flat)](https://rubygems.org/gems/vector2d)
[![Build](https://github.com/elektronaut/vector2d/actions/workflows/build.yml/badge.svg)](https://github.com/elektronaut/vector2d/actions/workflows/build.yml)

# Vector2d

Vector2d handles two-dimensional coordinates and vectors.
Vectors are immutable, meaning this is a purely functional library.

## Quick example

```ruby
require 'vector2d'

vector = Vector2d(50, 70)

vector.aspect_ratio        # => 0.7142857142857143
vector.length              # => 86.02325267042627

vector * 2                 # => Vector2d(100,140)
vector + Vector2d(20, 30)  # => Vector2d(70,100)

vector.fit(Vector2d(64, 64)) # => Vector2d(45.714285714285715,64.0)

Vector2d.parse([50, 70])   # => Vector2d(50,70)
Vector2d.parse("50x70")    # => Vector2d(50,70)
```

## Parsing

`Vector2d.parse` takes numbers, arrays, hashes, strings and other
vectors. Strings are written as `"50x70"` or `"50,70"`; the separator
is case insensitive and whitespace is ignored. Coordinates can be
signed, and they keep their type.

```ruby
Vector2d.parse("50x70")   # => Vector2d(50,70)
Vector2d.parse("50.0x70") # => Vector2d(50.0,70)
Vector2d.parse("-50X70")  # => Vector2d(-50,70)
Vector2d.parse("50, 70")  # => Vector2d(50,70)
Vector2d.parse("x70")     # => Vector2d(0,70)
```

Anything else raises `ArgumentError`.

## Documentation

[API documentation](https://rubydoc.info/gems/vector2d)

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/elektronaut/vector2d). See
[CONTRIBUTING.md](CONTRIBUTING.md) for how to run the tests and how
commits are formatted, and note that this project ships with a
[code of conduct](CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](LICENSE).
