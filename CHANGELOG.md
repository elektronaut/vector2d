# Changelog

## [3.0.0](https://github.com/elektronaut/vector2d/compare/vector2d/v2.3.0...vector2d/v3.0.0) (2026-09-20)

The public API grows from 43 methods to 115. Vectors are now genuinely
immutable and safe to share between ractors, they can be pattern matched,
and they convert to and from the standard library `Matrix` and `Vector`.

Nothing was removed. The seven deprecated methods still work, and stay
silent unless deprecation warnings are enabled.

Most of the breaking changes correct behavior that was undefined or plainly
wrong in 2.x: input that used to produce an unusable vector now raises where
the bad input is, rather than somewhere further along. Four changes can
affect code that works today, and they come first.

### Breaking changes

#### Ruby 3.4 is now the minimum, up from 3.2

`MatrixInterop#to_matrix`, `#to_vector` and `#transform` are not
ractor-safe before 3.4. Ruby 3.2 raises `Ractor::IsolationError` from the
`require`, and 3.3 raises out of `::Vector[]` even with `matrix` already
loaded. The floor moves so the matrix paths are safe across the whole
supported range, and the gemspec stops claiming versions CI never ran.

#### Vectors are frozen

Instances are frozen on construction, which is what makes them shareable
between ractors when their coordinates are. `#dup` and `clone(freeze: false)`
return frozen objects, matching `Data`, `Rational` and `Complex`.

A subclass that adds instance variables must assign them before calling
`super`, as the object is frozen by the time `super` returns.

#### Strings keep their coordinate type

`Vector2d.parse("50x70")` returns `Vector2d(50,70)` with `Integer`
coordinates. It previously returned floats, which made strings the one
input type that did not preserve what it was given.

Parsing is stricter about malformed input and more permissive about valid
input. `"1.2.3x4"` was accepted and silently truncated, and now raises.
Negative coordinates, an uppercase `X` separator and comma-separated pairs
are now accepted.

#### Coordinates must be `Numeric`

Coordinates were never validated, so any unrecognized argument fell through
to the constructor. `Vector2d.parse(nil)` returned `Vector2d(nil,nil)` and
raised `NoMethodError` later at an unrelated call site.

Every parse path now checks both coordinates. `Integer`, `Float`, `Rational`,
`BigDecimal` and custom `Numeric` subclasses are unaffected. Objects that
are numeric by duck typing alone are no longer accepted.

#### Tightened validation

These raise where 2.x returned something unusable. Code that was working is
unlikely to notice.

- `Vector2d(2, 0).aspect_ratio` returned `Infinity` and the zero vector
  returned `NaN`. Both now raise `ArgumentError`.
- `Complex` passed the coordinate check, and the resulting vector raised
  `RangeError` out of `Math` from `#aspect_ratio` and `.from_angle`. It is
  now rejected: `ArgumentError` from `.parse`, `.new` and `.from_angle`,
  `TypeError` from the operators.
- `Vector2d.parse(5, nil)` read the explicit `nil` as an omitted argument
  and returned `Vector2d(5,5)`. An explicit `nil` second argument now
  raises `ArgumentError`.
- `Vector2d(2, 3).clamp_length(-1.0)` returned a reversed unit vector
  rather than anything shorter. A negative maximum now raises
  `ArgumentError`, following `Comparable#clamp`. This applies to
  `#truncate` as well. Pass `max.clamp(0..)` to saturate instead.
  `#resize` is unchanged, where a negative length is a signed magnitude
  that reverses the vector.
- `#fit` and `#fit_either` returned early on the zero vector, before the
  argument was coerced, so `Vector2d(0, 0).fit("garbage")` returned the
  zero vector. Both now raise `ArgumentError`, as every other receiver
  already did.

#### Subclasses

Two places where a subclass could be dropped on the way through:

- `#coerce` built the left-hand operand with `.parse`, so `2 * subvector`
  returned a `Vector2d` where `subvector * 2` returned the subclass. It now
  builds through `#build`, so coercion is symmetric. `#coerce_vector` is
  unchanged, so methods that only read an operand's coordinates still parse
  into the base class.
- `.parse` returned any `Vector2d` argument untouched, so `Sub.parse(vector)`
  handed back the plain vector. An argument is returned as it is only when
  it is already an instance of the class parsing it; anything else is
  rebuilt through `.build`.

### Deprecations

All of these still work. They warn under `Warning[:deprecated] = true` or
`ruby -w`, and each one names its replacement.

| Deprecated          | Replacement                     |
| ------------------- | ------------------------------- |
| `#truncate`         | `#limit_length`                 |
| `#squared_length`   | `#length_squared`               |
| `#squared_distance` | `#distance_squared`             |
| `#fit_either`       | `#cover`                        |
| `#constrain_both`   | `#fit`                          |
| `#constrain_one`    | `#cover`                        |
| `#contain`          | `other.fit(self, upscale: false)` |

`#truncate` is the one worth looking at. It took a maximum length, where
`Numeric#truncate` takes a digit count, and the name went to the wrong
method. `#limit_length` replaces it.

### Features

#### Construction

`.build` and `#build` are the hooks every returning method routes through,
so a subclass overrides construction in one place.

- `Vector2d.from_angle(angle, length = 1.0)` and `#to_polar`
- `Vector2d.from_degrees(angle, length = 1.0)`
- `Vector2d.random(length = 1.0, random: Random)`
- `Vector2d.zero`, `.one`, `.up`, `.down`, `.left` and `.right`

#### Angles and rotation

- `#angle_to` returns a signed angle in `-PI..PI`, positive when the other
  vector is counterclockwise. `#angle_between` stays unsigned in `0..PI`.
- `Vector2d.degrees` and `.radians` convert between the two
- `#angle_in_degrees` and `#rotate_degrees`
- `#rotate_around(center, angle)`
- `#perpendicular_cw`, alongside the existing counterclockwise
  `#perpendicular`

#### Length and distance

- `#length_squared` and `#distance_squared`, which skip the square root
- `#manhattan_distance` and `#chebyshev_distance`
- `#limit_length(max)` scales down only if longer
- `#clamp_length(min, max = nil)` takes a range or a pair, mirroring
  `Comparable#clamp`
- `#direction_to`
- `#magnitude` and `#norm` as aliases of `#length`

#### Projection and reflection

- `#project`, `#reject` and `#scalar_projection`
- `#reflect(normal)` and `#refract(normal, refractive_index)`
- `#dot` and `#inner_product` as aliases of `#dot_product`

#### Interpolation

- `#lerp`, `#inverse_lerp` and `#slerp`
- `#midpoint`
- `#move_toward(target, distance)`

#### Comparison

- `#eql?` and `#hash`, so vectors work as hash keys
- `#approx_equal?(other, tolerance = nil)` and `#approx_zero?`
- `#zero?`, `#finite?` and `#nan?`
- `#parallel?`, `#perpendicular?`, `#opposite?` and `#independent?`

#### Component-wise operations

- Unary `+@` and `-@`
- `#abs`, `#sign` and `#snap(step)`
- `#with_x` and `#with_y`
- `#min` and `#max`
- `#floor` and `#ceil` take a digit count

#### Dimensions and fitting

- `#cover(other, upscale: true)` scales to the smallest size that fills the
  box, the counterpart to `#fit`
- `#fit(other, upscale: false)` never scales up
- `#fits?` and `#covers?`
- `#area`, `#square?`, `#portrait?` and `#landscape?`

#### Standard library compatibility

- `#to_matrix`, `#to_vector` and `#transform(matrix)`
- `#deconstruct` and `#deconstruct_keys` for pattern matching

### Bug fixes

- `#angle_between` is computed with `atan2` rather than
  `Math.acos(dot_product)`, which raised `Math::DomainError` whenever float
  normalization pushed the dot product past ±1.0. That happened for roughly
  15% of parallel and antiparallel pairs in a random probe. The zero vector
  now gives `0.0` instead of `NaN`. The range is unchanged.
- The angle converters always return floats, so a `BigDecimal` angle no
  longer leaks through.
- `#perpendicular` and `#rotate` preserve the receiver's class.
- `#inspect` renders the receiver's class.
- `#normalize` and `#resize` return the zero vector unchanged, where they
  previously returned `NaN` coordinates.
- `#reflect` guards against a zero normal, returning the vector unchanged.
- `#project` returns a float zero when projecting onto the zero vector.
- `#lerp` requires a real number as the amount.
- `#fit` and `#fit_either` handle negative vectors and zero coordinates by
  magnitude.
- `#==` returns false for non-vectors instead of raising.
- Scalar arguments are validated in the transformations.
- Internal files are loaded with `require_relative`.
- The gemspec has a `changelog_uri`.

### Performance improvements

Roughly 1.6x faster than the standard library `Vector` on the common
operations.

- Operands that are already usable skip the parser
- Coercion skips the parser for vectors
- The common coordinate types are checked first

## [2.3.0](https://github.com/elektronaut/vector2d/compare/vector2d-v2.2.4...vector2d/v2.3.0) (2026-08-30)


### Features

* Add Vector2d#clamp ([de77e58](https://github.com/elektronaut/vector2d/commit/de77e584f8f5668f24186179b720b4db9a70f6d2))
