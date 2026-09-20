# Changelog

## [3.0.0](https://github.com/elektronaut/vector2d/compare/vector2d/v2.3.0...vector2d/v3.0.0) (2026-09-20)


### ⚠ BREAKING CHANGES

* #coerce returns the other operand as an instance of the receiver's class, where it previously returned a Vector2d.
* .parse no longer returns a vector of another class as it is. Subclass.parse(vector) rebuilds it through .build, where it previously returned the argument.
* Ruby 3.4 is now the minimum version, up from 3.2.
* Vector2d instances are frozen. A subclass that adds instance variables must assign them before calling super, as the object is frozen by the time super returns.
* Complex is no longer accepted as a coordinate. Vector2d.parse, Vector2d.new and .from_angle raise ArgumentError, and the operators raise TypeError, where they previously returned a vector with complex components.
* Raise when clamping length to a negative max
* Vector2d.parse and Vector2d() now raise ArgumentError when the second argument is an explicit nil, instead of reading it as a request for a diagonal vector.
* #fit and #fit_either raise ArgumentError on invalid arguments when called on the zero vector, instead of returning it.
* Overhaul string parsing
* Raise when a vector has no aspect ratio
* Vector2d.parse now raises ArgumentError for nil, hashes missing :x or :y, non-Numeric coordinates, and arrays of the wrong length. Coordinates that are not Numeric are no longer accepted, including duck-typed numeric objects that previously passed through.
* angle_between now returns a signed angle in the range -PI..PI, positive when the second vector is counterclockwise from the first. It previously returned an unsigned angle in 0..PI.

### Features

* Accept a digit count in #floor and #ceil ([6fd0777](https://github.com/elektronaut/vector2d/commit/6fd07771247530ff8aa1e5eea9d5f237d43d8323))
* Accept a digit count in #floor and #ceil ([f09cc43](https://github.com/elektronaut/vector2d/commit/f09cc436b4832f422b65138d1c23e5a68076a4d5))
* Add .build and #build construction hooks ([50a48d3](https://github.com/elektronaut/vector2d/commit/50a48d38f64ced383a1b737ea6f59612a3ed3aee))
* Add .build and #build construction hooks ([efbd32d](https://github.com/elektronaut/vector2d/commit/efbd32d3254b4431bd6a8e9ff0d1fe04837b0e32))
* Add #angle_to, restore #angle_between to 0..PI ([ae839f3](https://github.com/elektronaut/vector2d/commit/ae839f371817f19268effe58b63c7fe60e27acea))
* Add #area and the shape predicates ([60841ec](https://github.com/elektronaut/vector2d/commit/60841ec2a66eaf35ef9e4b0f26ace96afbf5d8f9))
* Add #area, shape predicates, #fits?/#covers?, #snap and #trunc ([e1150dc](https://github.com/elektronaut/vector2d/commit/e1150dc147547a3f9ca8f0fca9a7311cd402bf6a))
* Add #clamp_length, #length_squared and #distance_squared ([cb6123e](https://github.com/elektronaut/vector2d/commit/cb6123e7bcce345f9e35118cb3828e1ef010f0e9))
* Add #cover and an upscale option to fitting ([96d76cc](https://github.com/elektronaut/vector2d/commit/96d76ccb0844bb008f17498d51cad3e99eb2609e))
* Add #cover and an upscale option, deprecate the legacy fitting API ([0c6ae6e](https://github.com/elektronaut/vector2d/commit/0c6ae6ec16aa018d46e73a32664a495950d519af))
* Add #fits? and #covers? ([2cd9d73](https://github.com/elektronaut/vector2d/commit/2cd9d73521248c959ed379a2321401b6160c55e6))
* Add #length_squared and #distance_squared ([dc5ca79](https://github.com/elektronaut/vector2d/commit/dc5ca79e6e56ee186b79a8f0d0f6688064dc2c9a))
* Add #lerp, #midpoint and Manhattan/Chebyshev distances ([19dcbfe](https://github.com/elektronaut/vector2d/commit/19dcbfe8ddaaaa48ca512bc37e3a7b566992767d))
* Add #lerp, #midpoint and Manhattan/Chebyshev distances ([87505d7](https://github.com/elektronaut/vector2d/commit/87505d79320eca17a2be04e4d185fcadafc536b0))
* Add #parallel? and #perpendicular_to? ([47deebf](https://github.com/elektronaut/vector2d/commit/47deebfdac8441df625f89050f03b1e7d2944c36))
* Add #parallel? and #perpendicular_to? ([15ef382](https://github.com/elektronaut/vector2d/commit/15ef382efa0589676df87b3b483fbdad3f249a77))
* Add #project, #reject, #scalar_projection and #reflect ([6d2cbfd](https://github.com/elektronaut/vector2d/commit/6d2cbfd44ac97e1a96ff4c01036dcf17da358710))
* Add #project, #reject, #scalar_projection and #reflect ([d4d2945](https://github.com/elektronaut/vector2d/commit/d4d2945c10bd5c9b70c1cfd5e545c882dd15a287))
* Add #rotate_around, #perpendicular_cw and #perpendicular_ccw ([06019e3](https://github.com/elektronaut/vector2d/commit/06019e3574bef668f2c75ac9c565ede43e2e6642))
* Add #snap and #trunc ([dc4aa06](https://github.com/elektronaut/vector2d/commit/dc4aa0695cb4d40d60bc6cda6849bcad1225c383))
* Add aliases matching the Vector API ([a17e3f0](https://github.com/elektronaut/vector2d/commit/a17e3f05519609f0aded97c0f32bc064318bf567))
* Add approximate equality, #slerp, #move_toward and six more ([591e81c](https://github.com/elektronaut/vector2d/commit/591e81c26b1b5e953306df3c9fe8711b8828cfcb))
* Add approximate equality, #slerp, #move_toward and six more ([e51d459](https://github.com/elektronaut/vector2d/commit/e51d459f25c32597aeb763a38c18094b7d740bf4))
* Add degree helpers to the angle API ([198673b](https://github.com/elektronaut/vector2d/commit/198673b40164c60ac2b8dc9eea6e45767a7a75ab))
* Add degree helpers to the angle API ([42e475a](https://github.com/elektronaut/vector2d/commit/42e475a206d4395da8bc6584d05f4c260bb05866))
* Add direction constants and four new methods ([88f1ce8](https://github.com/elektronaut/vector2d/commit/88f1ce82a2cd9fa560ead5515e6dbebd17c54df9))
* Add direction constants and four new methods ([c0a5f00](https://github.com/elektronaut/vector2d/commit/c0a5f004c24fbe25b09afd8ac9d3b8e8f29e24e9))
* Add Matrix and Vector interoperability ([b93de01](https://github.com/elektronaut/vector2d/commit/b93de01732dcb2d978398968a9caec42181a3126))
* Add Matrix and Vector interoperability ([11739d0](https://github.com/elektronaut/vector2d/commit/11739d00d1c585dee664cf9cc650025f2a885487))
* Add pattern matching support ([4185e9c](https://github.com/elektronaut/vector2d/commit/4185e9cb86a35b996fa14080941ed4a85d37e462))
* Add pattern matching support ([d2730cb](https://github.com/elektronaut/vector2d/commit/d2730cb3d0963738459c9ee9ccec69468752c97f))
* Add unary operators and component-wise operations ([c0fc8b2](https://github.com/elektronaut/vector2d/commit/c0fc8b2579917cd7b7aecaee0e24b7d9969a1825))
* Add unary operators and component-wise operations ([19bbde9](https://github.com/elektronaut/vector2d/commit/19bbde97c881f164c9bab4c0ef7c205891f8a18a))
* Add Vector2d.from_angle and #to_polar ([c52e3a3](https://github.com/elektronaut/vector2d/commit/c52e3a31b80df1623b1e55f5eddaa3182b9606a8))
* Add Vector2d.from_angle and #to_polar ([cb54e70](https://github.com/elektronaut/vector2d/commit/cb54e70c6a83d80023c529dee957467810e2f49b))
* Add Vector2d#clamp_length ([c632fd7](https://github.com/elektronaut/vector2d/commit/c632fd7ebbbe4aa3f08432f482b775e2fe37d7c5))
* Add Vector2d#eql? and #hash ([1fa536e](https://github.com/elektronaut/vector2d/commit/1fa536edf7e1daf454b65d9c1af6fddfb9a563bb))
* Add Vector2d#eql? and #hash ([a4e4c5e](https://github.com/elektronaut/vector2d/commit/a4e4c5e99f5c73e5b4eb27661752123da6143360))
* Add Vector2d#limit_length ([621d2bf](https://github.com/elektronaut/vector2d/commit/621d2bfc4d9373455f4545bd2f21178bb4a89f1d))
* Add Vector2d#limit_length ([05fe64a](https://github.com/elektronaut/vector2d/commit/05fe64a683bd1c3a5c7129bb09744c185fefd70e))
* Add Vector2d#zero? ([ae45f51](https://github.com/elektronaut/vector2d/commit/ae45f5108e5633c7dcebbb1cf2a13d44ef1ff71a))
* Deprecate #contain, #constrain_both and #constrain_one ([39f1eb6](https://github.com/elektronaut/vector2d/commit/39f1eb6c24f10f3e5be8ec86b39c6e3c1dbf9ce0))
* Deprecate legacy aliases and regroup the API by topic ([6cc96ce](https://github.com/elektronaut/vector2d/commit/6cc96ce9359ef8f708c586f93049edf0db2da2e6))
* Deprecate legacy aliases and settle API conventions ([1c71436](https://github.com/elektronaut/vector2d/commit/1c71436a9710c2830337fe927ea3cec4c6b6f6c0))
* Deprecate Vector2d#truncate ([05ba637](https://github.com/elektronaut/vector2d/commit/05ba63786fd9af7ca8fe58ee426fb32472184b62))
* Deprecate Vector2d#truncate ([0741ada](https://github.com/elektronaut/vector2d/commit/0741ada79123a6a4290dc0fec4e3d588bb2b83b0))
* Freeze vector instances ([d944446](https://github.com/elektronaut/vector2d/commit/d94444626b5b28b4baf23ea71f45fbc66d57f279))
* Split the angle API and add rotation helpers ([24006e1](https://github.com/elektronaut/vector2d/commit/24006e1887b4e4db8f399d889c182f7ad12e3a35))


### Bug Fixes

* Add changelog_uri to the gemspec metadata ([389667c](https://github.com/elektronaut/vector2d/commit/389667ca58fbc5b368779e1faba238367c68e18f))
* Add changelog_uri to the gemspec metadata ([c8bc4b3](https://github.com/elektronaut/vector2d/commit/c8bc4b3ac7b918f086a4b43ade4d5481d2ee828c))
* Always return floats from angle converters ([d04e4f6](https://github.com/elektronaut/vector2d/commit/d04e4f62080b80c7088aa6ca50091c7bbc5eea4b))
* Always return floats from angle converters ([b1ba0cb](https://github.com/elektronaut/vector2d/commit/b1ba0cbf7f953f297ad0f049d9fb8df21f985e85))
* compute angle_between with atan2 ([c248bd1](https://github.com/elektronaut/vector2d/commit/c248bd1c6d77b394b7254a222250823860654e35))
* Constrain fit_either by magnitude ([8f1bc0f](https://github.com/elektronaut/vector2d/commit/8f1bc0f6c14f2c465a23958aff10d9919c65fd17))
* Correct operand order in coercion TypeError ([f3f5140](https://github.com/elektronaut/vector2d/commit/f3f5140fd769ecfb2f4c8f650062d1343c1e66d4))
* Correct operand order in coercion TypeError ([4d791f0](https://github.com/elektronaut/vector2d/commit/4d791f0e104b98f1554a9a182aa50225c1fd61cc))
* Fit negative vectors by magnitude ([a74f083](https://github.com/elektronaut/vector2d/commit/a74f08369d6d104b2687c7f871616016220cb272))
* Freeze copies and require Ruby 3.4 ([21e20d4](https://github.com/elektronaut/vector2d/commit/21e20d42c882c12906c9a131062876b8cf2dbaf3))
* Guard #reflect against a zero normal ([0038d4d](https://github.com/elektronaut/vector2d/commit/0038d4d16b5ddfefabadf39ae3e285017d37092f))
* Guard against the zero vector when resizing ([f839167](https://github.com/elektronaut/vector2d/commit/f839167b8dc810a600f9cc6dc1be4c8f7f48c564))
* Guard against the zero vector when resizing ([b8b0a4b](https://github.com/elektronaut/vector2d/commit/b8b0a4b23b6a1c9de652e66ffda603cf39633ef9))
* Guard against zero coordinates when fitting ([929977a](https://github.com/elektronaut/vector2d/commit/929977a23f807421ae06f3af79e8c174f5063b36))
* Guard against zero coordinates when fitting ([b802a44](https://github.com/elektronaut/vector2d/commit/b802a44cf39d46229d42f9e180e658c5f84b8333))
* Handle non-Vector2d arguments in Vector2d#contain ([e3d2fa1](https://github.com/elektronaut/vector2d/commit/e3d2fa1c646761066675b137a8c1036eadcf9c6a))
* Keep the class through coercion ([0f29d72](https://github.com/elektronaut/vector2d/commit/0f29d720dc838f94b208605e119d46e06c2e1c2c))
* loosen Vector2d#normalized? tolerance ([8960438](https://github.com/elektronaut/vector2d/commit/8960438872931710401464180dde5bcf12a56cfc))
* loosen Vector2d#normalized? tolerance ([f18592c](https://github.com/elektronaut/vector2d/commit/f18592c454f3913c2814d1160874845cc8be9a4a))
* Overhaul string parsing ([47cf82b](https://github.com/elektronaut/vector2d/commit/47cf82be9275d8ed93cf9fce3bf19105e461302d))
* Preserve the receiver's class in perpendicular and rotate ([1ad67de](https://github.com/elektronaut/vector2d/commit/1ad67de5e04d865f39ee70296693f8d29abcb684))
* Preserve the receiver's class in perpendicular and rotate ([2aff4a3](https://github.com/elektronaut/vector2d/commit/2aff4a3961e25a7d5bc25a20cc43e567c17e8903))
* Raise when a vector has no aspect ratio ([ba32a10](https://github.com/elektronaut/vector2d/commit/ba32a10200cdea19418209c07d9ba2d2bffaf4b6))
* Raise when clamping length to a negative max ([73d5de2](https://github.com/elektronaut/vector2d/commit/73d5de26ed69fbd826aece57fab20449bef5582d))
* Rebuild a foreign vector in .parse ([92f37ee](https://github.com/elektronaut/vector2d/commit/92f37ee45d3d69b8a9343896aaab9ad645c9f03e))
* Reject an explicit nil y in Vector2d.parse ([6165abb](https://github.com/elektronaut/vector2d/commit/6165abb04c44be29c00c7fe750fb371dbd883b2b))
* Reject complex numbers as coordinates ([c60237d](https://github.com/elektronaut/vector2d/commit/c60237d36435a10d29f6f249e6d5c64fe83b5c1a))
* Reject invalid input in Vector2d.parse ([e1fabed](https://github.com/elektronaut/vector2d/commit/e1fabedbd6a6f5b3ee539775c4477fdc6715b8a7))
* Render the receiver's class in #inspect ([b458fcc](https://github.com/elektronaut/vector2d/commit/b458fcc59274be3a47f117e6a77594dde642ccc5))
* Render the receiver's class in #inspect ([a4c91e6](https://github.com/elektronaut/vector2d/commit/a4c91e6a97f9ea12ffb138f77ad06ee89ce763b5))
* Require a real number as the #lerp amount ([0a66f4f](https://github.com/elektronaut/vector2d/commit/0a66f4faa6ffb15c638bb301f1ce8defe0ce77b0))
* require internal files with require_relative ([beaf220](https://github.com/elektronaut/vector2d/commit/beaf22041c7184aa384109785ee01c1d2049d320))
* Return a float zero when projecting onto zero ([2ddd9d0](https://github.com/elektronaut/vector2d/commit/2ddd9d0b22e4b2b4b240da365e4e5b26b9c0cb62))
* Return a float zero when projecting onto zero ([b0438e3](https://github.com/elektronaut/vector2d/commit/b0438e39199296206ae3e1e5141200ead6a6df19))
* Return false when comparing to non-vectors ([5e13353](https://github.com/elektronaut/vector2d/commit/5e133538f11f1f7635fe1fbdac1757071d25b088))
* Return false when comparing Vector2d to non-vectors ([c9a7956](https://github.com/elektronaut/vector2d/commit/c9a7956539499de1be656c395c5a5afe704a1349))
* Stop #contain from scaling up an unconstrained vector ([1a82174](https://github.com/elektronaut/vector2d/commit/1a82174e171f5023ee701fd0e03d49f3658d74b4))
* Use coerced vector in Vector2d#contain ([4388362](https://github.com/elektronaut/vector2d/commit/43883621a1827daa8c4e17d094ffe9538d5adb23))
* Validate fitting arguments for the zero vector ([e38b2e0](https://github.com/elektronaut/vector2d/commit/e38b2e0747d56cf62947a2006c27f45152c33e76))
* Validate scalar arguments in transformations ([22f3f34](https://github.com/elektronaut/vector2d/commit/22f3f34896a63fc9deccb051ee851ff299ad2bcd))


### Performance Improvements

* Check the common coordinate types first ([7ce5a19](https://github.com/elektronaut/vector2d/commit/7ce5a19c96ebc6f367f09b3eabd7fe4857f08e9e))
* Skip parsing operands that are already usable ([aec0559](https://github.com/elektronaut/vector2d/commit/aec055942b008a59d867b2f8b27fe44978d792b0))
* Skip the parser for vectors when coercing ([b117f70](https://github.com/elektronaut/vector2d/commit/b117f70390dfbeb5bccccf5b295b735563300071))
* Stop parsing operands that are already usable ([5efdf71](https://github.com/elektronaut/vector2d/commit/5efdf710a4f2f9de7962d355fe3d5ae393c8f177))

## [2.3.0](https://github.com/elektronaut/vector2d/compare/vector2d-v2.2.4...vector2d/v2.3.0) (2026-08-30)


### Features

* Add Vector2d#clamp ([de77e58](https://github.com/elektronaut/vector2d/commit/de77e584f8f5668f24186179b720b4db9a70f6d2))
