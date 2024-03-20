# github-action-svu

GitHub Action for calculating Semantic Versions using [caarlos0/svu](https://github.com/caarlos0/svu)

I couldn't find a GitHub Action for `svu` that looked like it was being maintained, so I made one myself. I also put a dummy `go.mod` and `go.sum` file in the repo and then told dependabot to watch it for updates. My hope is that I made it easy enough to maintain that I won't be another unmaintaned `svu` Action.

All of the tooling in this repo scrapes the `svu` version directly out of that `go.mod` file, so it is the source of truth for what `svu` version is available from this action. To drive the point home, it's also included as build metadata on the versions of the Action. EG at the time of this being written, `svu` latest is `1.12.0` so this GitHub Action's version will be something like `v1.0.0+1.12.0`

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

### `svu` flags

Additionally, all flags that can be passed to `svu` exist as inputs for the Action:

- `build`
- `directory`
- `forcePatchIncrement`
- `pattern`
- `prefix`
- `preRelease`
- `stripPrefix`
- `tagMode`

Full details on all tags are available in `action.yaml`

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
