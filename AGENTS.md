# libdrm — agent guide

## Build (autotools)

```sh
./autogen.sh [--prefix=/usr --exec-prefix=/]
make
make install            # may need root for system prefix
```

First run from a git checkout **must** use `./autogen.sh` (runs `autoreconf` then `configure`). Re-running `./configure` with different flags is fine afterward.

`make distcheck` for release validation.

## Key configure flags

| Flag | Default | Notes |
|------|---------|-------|
| `--enable-udev` | no | enables udev-based device node discovery |
| `--enable-install-test-programs` | no | `make install` will also install test binaries |
| `--enable-cairo-tests` | auto | Cairo rendering in modetest |
| `--enable-manpages` | auto | needs xsltproc + docbook stylesheet |

Most driver APIs auto-detect (`--disable-*` to opt out): `intel`, `radeon`, `amdgpu`, `nouveau`, `vmwgfx`, `freedreno`, `vc4`. Experimental APIs need `--enable-*`: `omap-experimental-api`, `exynos-experimental-api`, `tegra-experimental-api`.

**C99 compiler required.** Atomic primitives (GCC `__sync_*` or libatomic-ops) are needed for most drivers.

## Tests

```sh
make check              # run all tests
```

- **amdgpu tests** need `cunit >= 2.1` (`apt install libcunit1-dev`).
- **libudev** needed for some test programs (`apt install libudev-dev`).
- `auth` and `lock` tests are marked `XFAIL_TESTS` (expected to fail).
- Tests in `tests/util/` built as a convenience library (`libutil.la`).

## Structure

- **Core library** (`libdrm.la`): root `xf86drm.c`, `xf86drmMode.c`, etc. — wraps DRM ioctls.
- **Driver libraries** (`libdrm_<name>.la`): each in its own directory (`intel/`, `radeon/`, `amdgpu/`, `nouveau/`, `freedreno/`, `omap/`, `exynos/`, `tegra/`, `vc4/`, `libkms/`). Each produces a `.pc` file.
- **Kernel headers**: `include/drm/*.h` are **copied from kernel source**. Update with:
  ```sh
  ./configure --with-kernel-source=/path/to/linux
  make copy-headers    # cp from kernel source
  make commit-headers  # copy + git add + commit
  ```
- **Android**: standalone `Android.mk` at root and in subdirectories.

## Symbol visibility

Driver-specific `*-symbol-check` scripts verify public ABI. Code uses `drm_private` (`__attribute__((visibility("hidden")))`) for internal symbols.

## Release

1. Bump version in `configure.ac`
2. `make distcheck`
3. Tag: `git tag -a 2.4.x -m "libdrm 2.4.x"`
4. Use `modular/release.sh` to upload + generate announce
