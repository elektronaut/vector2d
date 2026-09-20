# Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/elektronaut/vector2d). Everyone participating is
expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Getting started

Install the dependencies and run the test suite:

```sh
bundle install
bundle exec rspec
```

Check style before pushing:

```sh
bundle exec rubocop
```

## Pull requests

- Add tests for any behavior you change.
- Write commit messages using
  [Conventional Commits](https://www.conventionalcommits.org). The
  changelog and releases are generated from them, so the `feat:` and
  `fix:` prefixes decide what ends up in the next release.
- Leave the version and the changelog alone. Both are updated
  automatically when a release is cut.

## API conventions

Vectors are immutable. Every method that produces a vector returns a
new one, built through `#build` so that subclasses are preserved. The
naming rules below were settled for 3.0, and a new method is expected
to fit them rather than add a variant.

### Aliases

A method has one name, with two exceptions.

- **Standard library names.** Where `Vector` from the `matrix` gem
  names the same operation with the same kind of result, that name is
  an alias, so code written against `Vector` reads unchanged:
  `#magnitude` and `#norm` for `#length`, `#dot` and `#inner_product`
  for `#dot_product`, `#angle_with` for `#angle_between`. `Vector#cross`
  is deliberately not mirrored, because `#cross_product` returns the
  scalar z component here where `Vector#cross_product` returns a
  vector. `Vector#r` is not either, because the name says nothing on
  its own.
- **Deprecated names.** A renamed method keeps its old name for one
  major version. The old name warns and is removed in the next major.

There are no readability aliases. Two names for one operation means
every reader has to know both, so a name that is merely nicer than the
existing one is not added.

### Deprecations

A deprecated method calls `warn_deprecated` from `Vector2d::Deprecation`
with a message in the form `Vector2d#old is deprecated. Use #new
instead.`, and carries `@deprecated` in its doc comment. The warning is
in the `:deprecated` category, so it is silent unless deprecation
warnings are enabled, as with `ruby -w`. A deprecation ships in at
least one release before the method is removed. A name that has never
been in a release can be renamed outright.

Deprecated in 3.0, for removal in 4.0: `#contain`, `#constrain_both`,
`#constrain_one`, `#fit_either`, `#squared_distance`, `#squared_length`
and `#truncate`.

### Predicates

Predicates end in `?` and take the other vector as their argument, with
no preposition in the name: `#parallel?(other)`,
`#perpendicular?(other)`, `#opposite?(other)`, `#fits?(other)`. A
predicate can share its stem with a method that returns a vector, as
`#perpendicular?` does with `#perpendicular` and `#zero?` with `.zero`.

### Constructing vectors

`.new` takes exactly two real coordinates, and is the path every vector
goes through. `.parse` accepts anything that can be read as a vector,
and `Vector2d()` is its shorthand. `.build` is the hook a subclass
overrides when its constructor needs more than the coordinates, and is
not meant for callers. The remaining class methods, `.from_angle`,
`.from_degrees`, `.random` and the direction constants, build through
it.

### Modules

Methods are grouped by kind (`Properties`, `Transformations`,
`Calculations`, `Coercions`) unless a topic has enough of them to stand
on its own (`Clamping`, `Fitting`, `Interpolation`, `Optics`, `Degrees`,
`MatrixInterop`). `Coordinates` and `Deprecation` hold private helpers.
A `Metrics/ModuleLength` offence is a prompt to split out a topic, not
to raise the limit.
