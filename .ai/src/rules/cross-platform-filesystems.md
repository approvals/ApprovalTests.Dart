# Cross-Platform Filesystem Rules

## Paths

- Build paths with `package:path` or `Platform.pathSeparator`, not interpolated `/` or `\` separators.
- Compare expected `File.path` values using native paths built by `p.join`.
- Use `p.normalize(p.absolute(path))` before path identity or collision checks.
- Convert separators to POSIX form only for stable sort keys or portable serialized formats whose contract requires `/`.
- Keep discovered, displayed, and persisted filesystem paths native so they can be reopened on the host OS.
- Derive relative paths with `p.relative(..., from: ...)`; do not strip prefixes without checking path boundaries.
- Test relative ordering independently from the native path value returned to callers.

## Names and identity

- Preserve the package's portable filename policy for Windows-invalid characters, reserved device names, trailing dots/spaces, and 255-byte UTF-8 segments.
- Treat Windows path collision keys as case-insensitive after absolute normalization.
- Treat Linux paths as case-sensitive unless the test fixture explicitly models another filesystem.
- Do not assume a macOS volume is case-sensitive or case-insensitive; keep behavior defined by the package contract rather than the developer's disk.
- Include Windows drive letters and UNC paths in tests when changing absolute-path logic.
- Keep user-provided path segments separate from filenames and validate before the first write.

## File replacement

- Write replacement content to a unique temporary file in the target directory.
- Flush the temporary file before renaming it over the target.
- Use one filesystem replace/rename operation; delete-then-rename creates an observable gap.
- Preserve the replacement exception when temporary cleanup also fails.
- Remove temporary files after failures without deleting or truncating the existing approved artifact.
- Interpret Windows `FileSystemException("Cannot open file")` using `osError` or an existence probe; it may be a sharing violation rather than a missing path.
- Define atomic-write tests around observable invariants: every successful read is old or new complete content, the target remains present, and no temporary file remains after success.

## Tests and CI

- Create fixtures with `p.join` even when the local POSIX runner accepts `/`.
- Avoid expected strings that mix a native temp-directory prefix with a hard-coded separator.
- Exercise concurrency without fixed sleeps; wait for a condition and bound the loop.
- Run the same filesystem tests on `windows-latest`, `macos-latest`, and `ubuntu-latest`.
- Treat a platform-only failure as evidence about platform semantics before changing production behavior.
