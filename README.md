[![Version](https://img.shields.io/gem/v/vector2d.svg?style=flat)](https://rubygems.org/gems/vector2d)
![Build](https://github.com/elektronaut/vector2d/workflows/Build/badge.svg)
[![Code Climate](https://codeclimate.com/github/elektronaut/vector2d/badges/gpa.svg)](https://codeclimate.com/github/elektronaut/vector2d)
[![Code Climate](https://codeclimate.com/github/elektronaut/vector2d/badges/coverage.svg)](https://codeclimate.com/github/elektronaut/vector2d)
[![Inline docs](http://inch-ci.org/github/elektronaut/vector2d.svg)](http://inch-ci.org/github/elektronaut/vector2d)
[![Security](https://hakiri.io/github/elektronaut/vector2d/master.svg)](https://hakiri.io/github/elektronaut/vector2d/master)

# Vector2d

Vector2d handles two-dimensional coordinates and vectors.
Vectors are immutable, meaning this is a purely functional library.

## Quick example

```ruby
require 'vector2d'

vector = Vector2d(50, 70)

vector.aspect_ratio        # => 0.714285714285714
vector.length              # => 86.0232526704263

vector * 2                 # => Vector2d(100,140)
vector + Vector2d(20, 30)  # => Vector2d(70,100)

vector.fit(Vector2d(64, 64)) # => Vector2d(64,45)

Vector2d.parse([50, 70])   # => Vector2d(50,70)
Vector2d.parse("50x70")    # => Vector2d(50,70)
```

## Documentation

[API documentation](http://rdoc.info/github/elektronaut/vector2d)

## License

Copyright (c) 2006-2019 Inge Jørgensen

Vector2d is released under the [MIT License](http://www.opensource.org/licenses/MIT).
