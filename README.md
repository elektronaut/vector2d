[![Version](https://img.shields.io/gem/v/vector2d.svg?style=flat)](https://rubygems.org/gems/vector2d)
[![Build](https://github.com/elektronaut/vector2d/actions/workflows/build.yml/badge.svg)](https://github.com/elektronaut/vector2d/actions/workflows/build.yml)

# Vector2d

Vector2d is a library for handling two-dimensional vectors and coordinates.
It's fully featured, but has a particular focus on image processing, including constrained scaling and geometry string parsing.

It is strictly immutable and safe for use with Ractors.
It has no runtime dependencies, and is about 1.6x faster than the stdlib `Vector` class.
Every method is documented with examples in the [API documentation](https://rubydoc.info/gems/vector2d).

## Installation

Vector2d requires Ruby 3.4 or later. Add the gem to your Gemfile and run `bundle install`.

```ruby
gem "vector2d"
```

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

## Fitting

These are the three operations from web image sizing:

| Vector2d                     | Scales to                                    | CSS `object-fit` | ImageMagick geometry |
| ---------------------------- | -------------------------------------------- | ---------------- | -------------------- |
| `fit(other)`                 | the largest size that fits inside the box    | `contain`        | `WxH`                |
| `cover(other)`               | the smallest size that fills the box         | `cover`          | `WxH^`               |
| `fit(other, upscale: false)` | the largest size that fits, never scaling up | `scale-down`     | `WxH>`               |

```ruby
image = Vector2d(1600, 1200)
small = Vector2d(120, 90)
thumbnail = Vector2d(200, 200)

image.fit(thumbnail)   # => Vector2d(200.0,150.0)
image.cover(thumbnail) # => Vector2d(266.66666666666663,200.0)

small.fit(thumbnail)                 # => Vector2d(200.0,150.0)
small.fit(thumbnail, upscale: false) # => Vector2d(120,90)
```

The results are floats, use `#round` and `#to_s` to get a string representation to use with other tools.

```ruby
image.fit(thumbnail).round.to_s # => "200x150"
```

To constrain only one axis, leave the other blank or zero:

```ruby
image.fit(Vector2d("800x")) # => Vector2d(800.0,600.0)
image.fit(Vector2d(800, 0)) # => Vector2d(800.0,600.0)
```

`#fits?` and `#covers?` ask the question without doing the scaling.

```ruby
image.fits?(thumbnail)   # => false
small.fits?(thumbnail)   # => true
image.covers?(thumbnail) # => true
```

A vector doubles as a rectangle, and a few properties describe one.

```ruby
image.area         # => 1920000
image.aspect_ratio # => 1.3333333333333333
image.landscape?   # => true
image.portrait?    # => false
image.square?      # => false
```

## Parsing and coercion

`Vector2d.parse` is quite liberal: it accepts numbers, arrays, hashes, strings, other vectors, and the `Vector` and `Matrix` classes from the standard library.
Strings are written as `"50x70"` or `"50,70"`. The separator is case insensitive and whitespace is ignored.
Coordinates can be signed, and they retain their numeric type. It is also aliased as `Vector2d()` shorthand.

```ruby
Vector2d.parse("50x70")   # => Vector2d(50,70)
Vector2d.parse("50.0x70") # => Vector2d(50.0,70)
Vector2d.parse("-50X70")  # => Vector2d(-50,70)
Vector2d.parse("50, 70")  # => Vector2d(50,70)

Vector2d.parse([50, 70])         # => Vector2d(50,70)
Vector2d.parse({ x: 50, y: 70 }) # => Vector2d(50,70)
Vector2d.parse(50)               # => Vector2d(50,50)
```

Coordinates are real numbers: integers, floats, rationals and decimals.

This isn't limited to construction. Every method that takes a vector runs its argument through `.parse`, so all of the forms above work at any call site.

```ruby
Vector2d(2, 3).distance("5x7")           # => 5.0
Vector2d(2, 3).min([1, 5])               # => Vector2d(1,3)
Vector2d(23, 47).snap([10, 5])           # => Vector2d(20,45)
Vector2d(3, 4).approx_equal?([3.0, 4.0]) # => true
```

`#==` is the exception. It compares coordinates exactly and doesn't coerce, so that vectors stay usable as hash keys.

```ruby
Vector2d(3, 4) == [3, 4] # => false
```

`Vector2d.new` takes exactly two coordinates and nothing else.

## Arithmetic

Arithmetic operations have the same type semantics as Ruby numbers, so integer division truncates:

```ruby
vector = Vector2d(50, 70)

vector / 20   # => Vector2d(2,3)
vector / 20.0 # => Vector2d(2.5,3.5)
```

A scalar argument applies to both axes, and vectors coerce, so it can come first:

```ruby
vector - 10         # => Vector2d(40,60)
vector * 2          # => Vector2d(100,140)
2 * vector          # => Vector2d(100,140)
vector.max(60)      # => Vector2d(60,70)
vector.clamp(0, 60) # => Vector2d(50,60)
```

A vector argument applies one axis at a time:

```ruby
vector + Vector2d(20, 30)    # => Vector2d(70,100)
vector.min(Vector2d(60, 60)) # => Vector2d(50,60)
```

Unary `-` points a vector the other way, and `#reverse` is the same thing spelled out:

```ruby
-vector        # => Vector2d(-50,-70)
vector.reverse # => Vector2d(-50,-70)
```

`#with_x` and `#with_y` replace a single axis:

```ruby
vector.with_x(100) # => Vector2d(100,70)
vector.with_y(100) # => Vector2d(50,100)
```

`#round`, `#ceil` and `#floor` work one axis at a time, the way their counterparts on Ruby's numerics do, and all three take a number of digits.

```ruby
Vector2d(2.44, 3.66).round     # => Vector2d(2,4)
Vector2d(2.44, 3.66).ceil      # => Vector2d(3,4)
Vector2d(2.44, 3.66).floor     # => Vector2d(2,3)
Vector2d(2.44, 3.66).round(1)  # => Vector2d(2.4,3.7)
```

`#snap` rounds each axis to the nearest multiple of a step.

```ruby
Vector2d(23, 47).snap(10) # => Vector2d(20,50)
```

`#abs` drops the signs and `#sign` reduces each axis to -1, 0 or 1.

```ruby
Vector2d(-2.5, 3.5).abs  # => Vector2d(2.5,3.5)
Vector2d(-2.5, 3.5).sign # => Vector2d(-1,1)
```

## Length and distance

`#resize` scales a vector to a given length and `#normalize` scales it to one.
`#limit_length` caps the length at a maximum and `#clamp_length` bounds it at both ends, scaling a short vector up to the minimum.
All of them keep the direction, and `#clamp_length` takes its bounds the way `#clamp` does, as two arguments or as a range.

```ruby
vector = Vector2d(3, 4)

vector.length         # => 5.0
vector.length_squared # => 25
vector.normalize      # => Vector2d(0.6000000000000001,0.8)
vector.resize(10)     # => Vector2d(6.0,8.0)

vector.limit_length(3)      # => Vector2d(1.7999999999999998,2.4)
vector.limit_length(10)     # => Vector2d(3.0,4.0)
vector.clamp_length(10, 20) # => Vector2d(6.0,8.0)
vector.clamp_length(1..3)   # => Vector2d(1.7999999999999998,2.4)
```

`#normalized?` asks whether a vector is already of length one.
Distances come in the usual flavours, and `#direction_to` is the unit vector pointing from one vector to another.

```ruby
origin = Vector2d(2, 3)

origin.distance("5x7")            # => 5.0
origin.distance_squared([5, 7])   # => 25
origin.manhattan_distance([5, 7]) # => 7
origin.chebyshev_distance([5, 7]) # => 4
origin.direction_to([5, 7])       # => Vector2d(0.6000000000000001,0.8)
```

## Angles and rotation

Angles are radians, measured from the positive x axis.
Positive angles turn counterclockwise, and so do `#rotate` and `#perpendicular`.
The y axis grows upwards, putting `Vector2d.up` at `(0, 1)`.

```ruby
Vector2d.right # => Vector2d(1,0)
Vector2d.up    # => Vector2d(0,1)
Vector2d.left  # => Vector2d(-1,0)
Vector2d.down  # => Vector2d(0,-1)

Vector2d.up.angle                         # => 1.5707963267948966
Vector2d(2, 3).perpendicular              # => Vector2d(-3,2)
Vector2d.up.angle_to(Vector2d.right)      # => -1.5707963267948966
Vector2d.up.angle_between(Vector2d.right) # => 1.5707963267948966
```

`#rotate` turns a vector about the origin and `#rotate_around` about another point.
`#perpendicular` is a quarter turn counterclockwise, `#perpendicular_cw` the other way.
`Vector2d.from_angle` builds a vector from an angle and a length, and `#to_polar` takes one apart again.

```ruby
Vector2d(2, 3).perpendicular_cw                    # => Vector2d(3,-2)
Vector2d(2, 1).rotate_around([1, 1], Math::PI / 2) # => Vector2d(1.0,2.0)

Vector2d.from_angle(0, 5) # => Vector2d(5.0,0.0)
Vector2d(3, 4).to_polar   # => [5.0, 0.9272952180016122]
```

Where degrees are easier to read, there are convenience methods for them.

```ruby
Vector2d.from_degrees(45)         # => Vector2d(0.7071067811865476,0.7071067811865475)
Vector2d.up.angle_in_degrees      # => 90.0
Vector2d(2, 3).rotate_degrees(90) # => Vector2d(-3.0,2.0)

Vector2d.radians(90)       # => 1.5707963267948966
Vector2d.degrees(Math::PI) # => 180.0
```

## Comparison

`#==` compares coordinates exactly, so use `#approx_equal?` on anything you've done arithmetic to.
Its default tolerance, the one `#parallel?` and `#perpendicular?` use, is a few ulps scaled by the magnitude of the vectors; a tolerance of your own is an absolute distance, and isn't scaled.

```ruby
drifted = Vector2d(0.1, 0.2) * 3

drifted                           # => Vector2d(0.30000000000000004,0.6000000000000001)
drifted == Vector2d(0.3, 0.6)     # => false
drifted.approx_equal?([0.3, 0.6]) # => true

Vector2d(1e-20, 0).zero?        # => false
Vector2d(1e-20, 0).approx_zero? # => true
```

`#eql?` is stricter still and tells coordinate types apart, and `#hash` follows it, so the two vectors below are different hash keys.

```ruby
Vector2d(3, 4) == Vector2d(3.0, 4.0)    # => true
Vector2d(3, 4).eql?(Vector2d(3.0, 4.0)) # => false
```

The directional predicates compare directions and ignore magnitudes, and `#finite?` and `#nan?` ask about the coordinates.

```ruby
Vector2d(2, 3).parallel?([-4, -6])     # => true
Vector2d(2, 3).opposite?([-4, -6])     # => true
Vector2d(2, 3).perpendicular?([-3, 2]) # => true
Vector2d(2, 3).independent?([3, 2])    # => true
```

## Pattern matching

Vectors deconstruct to an array or a hash, so they can be matched against either kind of pattern.

```ruby
case Vector2d(3, 4)
in [0, 0] then :origin
in [Integer => x, Integer => y] then x + y
end # => 7

case Vector2d(0, 4)
in {x: 0} then :on_y_axis
in {y: 0} then :on_x_axis
end # => :on_y_axis
```

## Conversions

A vector converts to the plain Ruby representations, `#to_s` writes the geometry string back out, and `#to_i_vector` and `#to_f_vector` convert the coordinates while keeping the class.

```ruby
Vector2d(2.5, 3.5).to_a        # => [2.5, 3.5]
Vector2d(2.5, 3.5).to_hash     # => {x: 2.5, y: 3.5}
Vector2d(2.5, 3.5).to_s        # => "2.5x3.5"
Vector2d(2.5, 3.5).to_i_vector # => Vector2d(2,3)
Vector2d(2, 3).to_f_vector     # => Vector2d(2.0,3.0)
```

## Standard library compatibility

Vectors convert to and from the `Matrix` and `Vector` classes in the standard library, and the operators accept both.

```ruby
Vector2d(2, 3).to_vector         # => Vector[2, 3]
Vector2d(2, 3).to_matrix         # => Matrix[[2], [3]]
Vector2d.parse(Vector[2, 3])     # => Vector2d(2,3)
Vector2d.parse(Matrix[[2], [3]]) # => Vector2d(2,3)

Vector[1, 2] + Vector2d(3, 4)    # => Vector2d(4,6)
```

`#transform` multiplies a 2x2 matrix by the vector.

```ruby
Vector2d(3, 4).transform(Matrix[[0, -1], [1, 0]]) # => Vector2d(-4,3)
```

The `matrix` library is a bundled gem, so applications using these methods need `gem "matrix"` in their Gemfile. It's only loaded when a conversion needs it.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/elektronaut/vector2d).
See [CONTRIBUTING.md](CONTRIBUTING.md) for how to run the tests and how commits are formatted, and note that this project ships with a [code of conduct](CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](LICENSE).
