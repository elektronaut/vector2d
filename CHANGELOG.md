# Changelog

## [3.0.0](https://github.com/elektronaut/vector2d/compare/vector2d/v2.3.0...vector2d/v3.0.0) (2026-09-19)


### ⚠ BREAKING CHANGES

* Overhaul string parsing
* Raise when a vector has no aspect ratio
* Vector2d.parse now raises ArgumentError for nil, hashes missing :x or :y, non-Numeric coordinates, and arrays of the wrong length. Coordinates that are not Numeric are no longer accepted, including duck-typed numeric objects that previously passed through.
* angle_between now returns a signed angle in the range -PI..PI, positive when the second vector is counterclockwise from the first. It previously returned an unsigned angle in 0..PI.

### Features

* Add #clamp_length, #length_squared and #distance_squared ([cb6123e](https://github.com/elektronaut/vector2d/commit/cb6123e7bcce345f9e35118cb3828e1ef010f0e9))
* Add #length_squared and #distance_squared ([dc5ca79](https://github.com/elektronaut/vector2d/commit/dc5ca79e6e56ee186b79a8f0d0f6688064dc2c9a))
* Add Vector2d#clamp_length ([c632fd7](https://github.com/elektronaut/vector2d/commit/c632fd7ebbbe4aa3f08432f482b775e2fe37d7c5))
* Add Vector2d#eql? and #hash ([1fa536e](https://github.com/elektronaut/vector2d/commit/1fa536edf7e1daf454b65d9c1af6fddfb9a563bb))
* Add Vector2d#eql? and #hash ([a4e4c5e](https://github.com/elektronaut/vector2d/commit/a4e4c5e99f5c73e5b4eb27661752123da6143360))
* Add Vector2d#zero? ([ae45f51](https://github.com/elektronaut/vector2d/commit/ae45f5108e5633c7dcebbb1cf2a13d44ef1ff71a))


### Bug Fixes

* compute angle_between with atan2 ([c248bd1](https://github.com/elektronaut/vector2d/commit/c248bd1c6d77b394b7254a222250823860654e35))
* Correct operand order in coercion TypeError ([f3f5140](https://github.com/elektronaut/vector2d/commit/f3f5140fd769ecfb2f4c8f650062d1343c1e66d4))
* Correct operand order in coercion TypeError ([4d791f0](https://github.com/elektronaut/vector2d/commit/4d791f0e104b98f1554a9a182aa50225c1fd61cc))
* Guard against the zero vector when resizing ([f839167](https://github.com/elektronaut/vector2d/commit/f839167b8dc810a600f9cc6dc1be4c8f7f48c564))
* Guard against the zero vector when resizing ([b8b0a4b](https://github.com/elektronaut/vector2d/commit/b8b0a4b23b6a1c9de652e66ffda603cf39633ef9))
* Guard against zero coordinates when fitting ([929977a](https://github.com/elektronaut/vector2d/commit/929977a23f807421ae06f3af79e8c174f5063b36))
* Guard against zero coordinates when fitting ([b802a44](https://github.com/elektronaut/vector2d/commit/b802a44cf39d46229d42f9e180e658c5f84b8333))
* Handle non-Vector2d arguments in Vector2d#contain ([e3d2fa1](https://github.com/elektronaut/vector2d/commit/e3d2fa1c646761066675b137a8c1036eadcf9c6a))
* loosen Vector2d#normalized? tolerance ([8960438](https://github.com/elektronaut/vector2d/commit/8960438872931710401464180dde5bcf12a56cfc))
* loosen Vector2d#normalized? tolerance ([f18592c](https://github.com/elektronaut/vector2d/commit/f18592c454f3913c2814d1160874845cc8be9a4a))
* Overhaul string parsing ([47cf82b](https://github.com/elektronaut/vector2d/commit/47cf82be9275d8ed93cf9fce3bf19105e461302d))
* Preserve the receiver's class in perpendicular and rotate ([1ad67de](https://github.com/elektronaut/vector2d/commit/1ad67de5e04d865f39ee70296693f8d29abcb684))
* Preserve the receiver's class in perpendicular and rotate ([2aff4a3](https://github.com/elektronaut/vector2d/commit/2aff4a3961e25a7d5bc25a20cc43e567c17e8903))
* Raise when a vector has no aspect ratio ([ba32a10](https://github.com/elektronaut/vector2d/commit/ba32a10200cdea19418209c07d9ba2d2bffaf4b6))
* Reject invalid input in Vector2d.parse ([e1fabed](https://github.com/elektronaut/vector2d/commit/e1fabedbd6a6f5b3ee539775c4477fdc6715b8a7))
* Render the receiver's class in #inspect ([b458fcc](https://github.com/elektronaut/vector2d/commit/b458fcc59274be3a47f117e6a77594dde642ccc5))
* Render the receiver's class in #inspect ([a4c91e6](https://github.com/elektronaut/vector2d/commit/a4c91e6a97f9ea12ffb138f77ad06ee89ce763b5))
* require internal files with require_relative ([beaf220](https://github.com/elektronaut/vector2d/commit/beaf22041c7184aa384109785ee01c1d2049d320))
* Return false when comparing to non-vectors ([5e13353](https://github.com/elektronaut/vector2d/commit/5e133538f11f1f7635fe1fbdac1757071d25b088))
* Return false when comparing Vector2d to non-vectors ([c9a7956](https://github.com/elektronaut/vector2d/commit/c9a7956539499de1be656c395c5a5afe704a1349))
* Use coerced vector in Vector2d#contain ([4388362](https://github.com/elektronaut/vector2d/commit/43883621a1827daa8c4e17d094ffe9538d5adb23))

## [2.3.0](https://github.com/elektronaut/vector2d/compare/vector2d-v2.2.4...vector2d/v2.3.0) (2026-08-30)


### Features

* Add Vector2d#clamp ([de77e58](https://github.com/elektronaut/vector2d/commit/de77e584f8f5668f24186179b720b4db9a70f6d2))
