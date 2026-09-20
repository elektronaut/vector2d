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

## Dimensions

Vector2d grew out of handling image dimensions, and a few properties
describe a vector as a rectangle.

```ruby
vector = Vector2d(50, 70)

vector.area         # => 3500
vector.aspect_ratio # => 0.7142857142857143

vector.portrait?    # => true
vector.landscape?   # => false
vector.square?      # => false
```

All of these compare coordinates by magnitude, so a negative vector
describes the same rectangle as its positive twin.

```ruby
Vector2d(-50, 70).aspect_ratio # => 0.7142857142857143
```

Exactly one of `#square?`, `#landscape?` and `#portrait?` is true for
any vector. `#aspect_ratio` raises when there is no height to divide
by, but the predicates don't single out the zero vector. It is square.

```ruby
Vector2d(50, 0).aspect_ratio # => ArgumentError
Vector2d(0, 0).square?       # => true
```

## Fitting

`#fit` scales a vector until it is contained by another; `#cover`
scales until it contains it. Both keep the aspect ratio and the
direction, and both scale in either direction.

```ruby
vector = Vector2d(300, 300)

vector.fit(Vector2d(200, 150))   # => Vector2d(150.0,150.0)
vector.cover(Vector2d(200, 150)) # => Vector2d(200.0,200.0)
```

Pass `upscale: false` to scale down only, leaving a vector that is
already small enough alone.

```ruby
vector = Vector2d(100, 100)

vector.fit(Vector2d(200, 150))                 # => Vector2d(150.0,150.0)
vector.fit(Vector2d(200, 150), upscale: false) # => Vector2d(100,100)
```

`#fits?` and `#covers?` ask the question without doing the scaling.

```ruby
constraint = Vector2d(200, 150)

Vector2d(100, 100).fits?(constraint)   # => true
Vector2d(300, 300).fits?(constraint)   # => false

Vector2d(300, 300).covers?(constraint) # => true
Vector2d(100, 100).covers?(constraint) # => false
```

An axis that is zero doesn't constrain anything. This is how you fit to
a width and let the height follow.

```ruby
Vector2d(300, 300).fit(Vector2d(200, 0)) # => Vector2d(200.0,200.0)
```

## Rounding

`#round`, `#ceil` and `#floor` work one axis at a time, and round the
way their counterparts on Ruby's numerics do. All three take an
optional number of digits.

```ruby
vector = Vector2d(2.44, 3.66)

vector.round # => Vector2d(2,4)
vector.ceil  # => Vector2d(3,4)
vector.floor # => Vector2d(2,3)

vector.round(1) # => Vector2d(2.4,3.7)
```

There is no component-wise truncation toward zero yet. `#truncate` is
deprecated and still means `#clamp_length`, which scales the whole
vector down to a maximum length rather than working per axis, so the
name stays occupied until that deprecation is removed.

`#snap` rounds each axis to the nearest multiple of a step. The step is
coerced like any other argument, and a vector gives each axis its own.

```ruby
Vector2d(23, 47).snap(10)              # => Vector2d(20,50)
Vector2d(23, 47).snap(Vector2d(10, 5)) # => Vector2d(20,45)
Vector2d(2.3, 3.7).snap(0.5)           # => Vector2d(2.5,3.5)
```

## Angles

Every angle in this library is in radians, both in and out. There are no
degree variants; use `* 180 / Math::PI` to convert when you need to.

Positive angles turn counterclockwise, which is the direction `#rotate`
and `#perpendicular` turn in.

There are two ways to measure the angle between two vectors, and they
differ in whether the direction of rotation is part of the answer.

```ruby
v1 = Vector2d(2, 3)
v2 = Vector2d(4, 5)

v1.angle_to(v2)      # => -0.08673833867598511
v2.angle_to(v1)      # => 0.08673833867598511

v1.angle_between(v2) # => 0.08673833867598511
v2.angle_between(v1) # => 0.08673833867598511
```

`#angle_to` is signed and ranges over `-PI..PI`. It is positive when the
other vector is counterclockwise from this one, so reversing the
arguments flips the sign.

`#angle_between` is unsigned and ranges over `0..PI`. It is the
magnitude of `#angle_to`, so the order does not matter.

Both ignore the magnitudes of the vectors. The zero vector has no
direction, so any angle involving it is zero.

## Standard library compatibility

Vectors convert to and from the `Matrix` and `Vector` classes in the
standard library.

```ruby
Vector2d(2, 3).to_vector         # => Vector[2, 3]
Vector2d(2, 3).to_matrix         # => Matrix[[2], [3]]
Vector2d.parse(Vector[2, 3])     # => Vector2d(2,3)
Vector2d.parse(Matrix[[2], [3]]) # => Vector2d(2,3)
```

The `matrix` library is a bundled gem, so applications using these
methods need `gem "matrix"` in their Gemfile. It is only loaded when a
conversion needs it.

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
