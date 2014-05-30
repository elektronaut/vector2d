# Vector2d [![Build Status](https://travis-ci.org/elektronaut/vector2d.png)](https://travis-ci.org/elektronaut/vector2d) [![Code Climate](https://codeclimate.com/github/elektronaut/vector2d.png)](https://codeclimate.com/github/elektronaut/vector2d)

Vector2d handles two-dimensional coordinates and vectors.
Vectors are immutable, meaning this is a purely functional library.

## Quick example

    require 'vector2d'

    vector = Vector2d(50, 70)

    vector.aspect_ratio        # => 0.714285714285714
    vector.length              # => 86.0232526704263

    vector * 2                 # => Vector2d(140,100)
    vector + Vector2d(20, 30)  # => Vector2d(100,70)

    vector.fit(Vector(64, 64)) # => Vector2d(64,45)

    Vector2d.parse([50, 70])   # => Vector2d(50,70)
    Vector2d.parse("50x70")    # => Vector2d(50,70)

## Documentation

[API documentation](http://rdoc.info/github/elektronaut/vector2d)

## License

Vector2d is released under the [MIT License](http://www.opensource.org/licenses/MIT).