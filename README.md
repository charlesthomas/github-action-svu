# github-action-svu

GitHub Action for calculating Semantic Versions using [caarlos0/svu](https://github.com/caarlos0/svu)

I couldn't find a GitHub Action for `svu` that looked like it was being maintained, so I made one myself. My hope is that I made it easy enough to maintain that I won't be another unmaintaned `svu` Action.

# Using this GitHub Action

## Inputs

There are 3 inputs that are specific to this GitHub Action, and are not passed to `svu`:

### `clone`

If `true`, `clone` will clone the repo before running `svu`. This is useful if you aren't using `actions/checkout` or some other way to checkout your repo.

### `unshallow`

If `clone` is `false` and `unshallow` is `true`, then `git fetch --unshallow` will be run before running `svu`. `actions/checkout` does a clone with depth 1 by default and doesn't include tags. If you don't have a full copy of the repo and all of the tags fetched, `svu` can miscalculate the next version.

### `pushTag`

If `pushTag` is `true` and `svu` calculates a new version (ie `svu current` and `svu next` output different strings), then the following commands will be run:

- `git tag $next`
- `git push --tags`

This is useful if you don't want to explicitly confirm the version change and push the tags yourself.

### `cmd`

The `svu` sub-command (eg `next`, `current`, `major`, etc) uses the `cmd` input.

### `svu v3` flags

#### Global flags

These flags work with any of the `next` / `major` / `patch` etc commands:

- `tagMode`
- `tagPattern`
- `tagPrefix`
- `verbose`

#### Prerelease flags

Works if `cmd` is `prerelease`:

- `prerelease`

#### Next flags

Work if `cmd` is `next`:

- `always`
- `logDirectory`
- `metadata`
- `prelease`
- `v0`

Full details on all tags are available in `action.yaml`

### Legacy Inputs

In v3 most `svu` flags were renamed. The following Inputs should still work, so that this action doesn't need a major version bump.

USE CAUTION when combining v3 Inputs with legacy Inputs! v3 always takes precedence. eg if you set `build: nothing` AND `metadata: something` then the `metadata: something` will be used and `build: nothing` will be ignored

- `build`
    - becomes `metadata`
- `directory`
    - becomes `logDirectory`
- `forcePatchIncrement`
    - becomes `always`
- `pattern`
    - becomes `tagPattern`
- `prefix`
    - becomes `tagPrefix`

## Outputs

This GitHub Action has up to three outputs:

### `current`

`current` is the output of `svu current` and is always output by the action.

### `next`

`next` is the output of any `svu` command other than `current`:

- `major`
- `minor`
- `next`
- `prerelease`

If the `cmd` input is `current` then `next` will not be output.

### `changed`

`changed` is `false` if `cmd` input is `current` and when the outputs of `current` and `next` are identical.

If `svu` calculated a new version (`current` and `next` are different), then `changed` will be `true`. This is useful if you want to push the tag yourself, or if you want to only run subsequent steps in an action if there's a new version.

# Releasing a New Version of this GitHub Action

The CD for this repo is only triggered when a new tag is pushed. Pushing a new tag is automated:

```bash
make tag
```

This will do the following:
- Calculate the new version (again: including the `svu` version as build metadata)
- Update the image reference in `action.yaml` to be that new version
- Commit & push the `action.yaml` change
- Make a new `git tag` with the same version
- Push the new tag

At that point CD will take over and build & publish the image and cut a GitHub Release
