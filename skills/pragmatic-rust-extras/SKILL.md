---
name: pragmatic-rust-extras
description: "The parts of Microsoft's Pragmatic Rust Guidelines that Google's Rust style guide does not cover: extra lints and CI tools, performance, structured logging, FFI, macro crates, testability, workspace layout, docs, and rules for AI-written code. An add-on to google-rust-style, never a replacement: Google wins every overlap, and Microsoft rules that clash with Google are left out. Use alongside google-rust-style when writing, reviewing or setting up Rust, especially for hot paths, logging, FFI, proc macros, crate and workspace layout, or test seams."
---

# Pragmatic Rust extras

Source: [Microsoft Pragmatic Rust Guidelines](https://microsoft.github.io/rust-guidelines/), version 2026.6, read 2026-11-17. Each rule names its guideline ID, which is also the anchor on that chapter's page: `https://microsoft.github.io/rust-guidelines/guidelines/<chapter>/index.html#<ID>`. The chapter is in each section heading.

**Load google-rust-style first.** This skill only adds to it. When the two disagree, follow Google. The Microsoft rules that clash with Google are not here; [Left out](#left-out) lists them, so you don't bring them back from memory.

The *library* and *application* labels mean the same as in google-rust-style.

## 1. Lints and tools (universal)

Merge these into the `[lints]` tables from google-rust-style. They are the Microsoft lints that agree with Google, checked against a real workspace ([M-STATIC-VERIFICATION]). All are known to clippy 1.99.

```toml
[lints.rust]
ambiguous_negative_literals = "warn"
missing_debug_implementations = "warn"
redundant_imports = "warn"
redundant_lifetimes = "warn"
trivial_numeric_casts = "warn"
unsafe_op_in_unsafe_fn = "warn"
unused_lifetimes = "warn"

[lints.clippy]
allow_attributes_without_reason = "warn"
as_pointer_underscore = "warn"
assertions_on_result_states = "warn"
clone_on_ref_ptr = "warn"
deref_by_slicing = "warn"
disallowed_script_idents = "warn"
empty_drop = "warn"
empty_enum_variants_with_brackets = "warn"
empty_structs_with_brackets = "warn"
fn_to_numeric_cast_any = "warn"
renamed_function_params = "warn"
semicolon_outside_block = "warn"
unnecessary_safety_comment = "warn"
unnecessary_safety_doc = "warn"
unneeded_field_pattern = "warn"
unused_result_ok = "warn"
too_long_first_doc_paragraph = "warn"
```

Left out of Microsoft's table on purpose:
- The `pedantic` and `cargo` groups. They swap Google's targeted lint set for hundreds of lints, and some `pedantic` lints work against Google's naming.
- `redundant_type_annotations`. It fights Google's rule to annotate types a reader can't infer.
- `if_then_some_else_none`. It pushes `bool::then` closures where Google prefers plain control flow.
- `map_err_ignore`. It wants every mapped error kept as a source, which works against Google's small `Copy` error types, such as a decoder's `Malformed("field")`.

Most hits are mechanical, but clippy marks many suggestions as possibly wrong, so `cargo clippy --fix` skips them. Three traps when applying them by hand:

- `clone_on_ref_ptr` suggests `std::sync::Arc::<T>::clone(&x)`. Shorten it to `Arc::clone(&x)` with `use std::sync::Arc;`, as Google names types. Keep the `::<T>` only where the clone coerces to an `Arc<dyn Trait>`, which won't compile without it.
- `empty_enum_variants_with_brackets` changes behavior under serde. In an untagged enum, `Empty {}` matches the JSON `{}` and a unit `Empty` doesn't. Keep the brackets there, with an `#[expect]`.
- `semicolon_outside_block` can extend a borrow past the block, such as a database table borrowed from a transaction you commit after the block. It also clashes with `no_effect` on a `#[cfg]` block holding one assignment; write `if cfg!(..) { .. }` there instead.

CI gates beyond clippy and rustfmt ([M-STATIC-VERIFICATION]):
- `cargo audit` for advisories in dependencies.
- `cargo hack --feature-powerset check` for libraries with features.
- `cargo udeps` (nightly) for unused dependencies.
- `cargo +nightly miri test` on every crate that contains `unsafe` ([M-UNSAFE]).

`#[allow(..)]` is fine in generated code and macro output ([M-LINT-OVERRIDE-EXPECT]). Everywhere else use `#[expect(.., reason = "..")]`, as Google says.

## 2. Universal rules (universal)

- Public types implement `Debug`. A type holding secrets gets a hand-written `Debug` that redacts them, plus a unit test asserting the secret is missing from its `Debug` output. [M-PUBLIC-DEBUG]
- Types meant to be read by people, such as errors and string-like wrappers, implement `Display`. [M-PUBLIC-DISPLAY]
- If in doubt, split the crate. Features unlock extra functionality; independently usable parts are separate crates, re-joined by an umbrella crate if needed. [M-SMALLER-CRATES]
- No weasel words in names: `Service`, `Manager`, `Factory`. A builder is `FooBuilder`. Take `impl Fn() -> Foo` instead of a factory type. [M-WEASEL-WORDS]
- An associated function either creates the type or implements a trait. Other receiver-less computation is a free function. [M-REGULAR-FN]
- Magic values get a named `const` and a comment on why that value, its side effects, and which external system depends on it. [M-DOCUMENTED-MAGIC]

## 3. Logging (universal, resilience, performance)

- Log structured events with message templates (messagetemplates.org), such as `tracing`'s `event!`. Never build the message with `format!`. Name events `<component>.<operation>.<state>`. Use OpenTelemetry semantic-convention attribute names such as `file.path`, `http.request.method` and `error.type`. Redact PII, for example with the `data_privacy` crate. [M-LOG-STRUCTURED]
- Production and library code logs through telemetry, never `println!` or `dbg!`. CLIs may print their output. [M-LOG-NOT-PRINT]
- Keep telemetry out of hot loops, or make it cheap and allocation-free. Log a batch id rather than every item. [M-LOG-OVERHEAD]

If you turn on clippy's `literal_string_with_formatting_args`, allow it, since message templates trip it.

## 4. Library API shape (libs/interop, libs/ux, libs/resilience)

*Library* rules. *Application* code takes them as recommendations, as with Google's API rules.

**Interop**
- Public types and futures are `Send`. Check it with `const fn assert_send<T: Send>() {}`. An `Rc` held across `.await` makes a future `!Send`. A type used only momentarily may be `!Send`. [M-TYPES-SEND]
- A wrapper around a native handle offers `unsafe fn from_native()` and `into_native()`/`to_native()`, each documenting its safety requirements. [M-ESCAPE-HATCHES]
- Don't leak third-party types through your API. Prefer std types, and expose others only behind a feature (such as `serde`) or for a substantial benefit. [M-DONT-LEAK-TYPES]
- Never `pub use` another crate's items. Umbrella crates, technical crate splits and hidden macro paths are the exceptions. [M-FOREIGN-REEXPORTS]
- Take `impl RangeBounds<T>` instead of `(start, end)` pairs. [M-IMPL-RANGEBOUNDS]
- Sans-IO: a one-shot I/O function takes `impl std::io::Read`/`Write`, or `futures::io::AsyncRead`/`AsyncWrite` so it works on any runtime. [M-IMPL-IO]

**Shape**
- Abstractions nest at most one level in public signatures: `Foo<Bar>`, never `Foo<Bar<Baz>>`. [M-SIMPLE-ABSTRACTIONS]
- Prefer concrete types, then generics, then `dyn Trait`. Keep traits narrow (`StoreObject`, `LoadObject`). For sans-IO test doubles, use an enum. Wrap a `dyn` in your own struct. [M-DI-HIERARCHY]
- Convert errors with `impl From<Other> for Error` and `?`. Use `map_err` only for foreign error types or to add context. [M-FROM-ERROR]
- Four or more construction permutations get a builder. `Foo::builder()` returns `FooBuilder`, its chainable setters take the field's name, and `.build()` finishes. [M-INIT-BUILDER]
- Setters on a builder are infallible. `.build()` returns `Result` and does the cross-field validation. [M-BUILD-RESULT]
- Four or more constructor parameters get grouped into semantic types: `Deposit::new(account, amount)`. [M-INIT-CASCADED]
- Core behavior lives in inherent methods. Trait impls forward to them. [M-ESSENTIAL-FN-INHERENT]
- Modules are balanced, and each covers one topic (`account`, `network`). Never group by kind (`traits`, `errors`). [M-BALANCED-MODULES]
- Parameter order is consistent. The same concept goes in the same position, call-specific parameters come first, ubiquitous ones such as `&logger` come last, and at most one closure. [M-PARAMETER-CONSISTENCY]
- A custom collection implements `Iterator` types for `T`, `&T` and `&mut T`, plus `FromIterator`, `Extend`, and `DoubleEndedIterator`/`ExactSizeIterator` where they fit. Its `size_hint` is truthful. [M-COLLECTION-TRAITS]
- Write `async fn` rather than returning `impl Future`. Exceptions are traits and hot paths that need a smaller future ([M-ASYNC-STACK-SIZE]). [M-ASYNC-FN]

**Types**
- Use the strongest std type: `Path`/`PathBuf` for OS paths, not `String`. Numeric primitives stay plain at API boundaries. [M-STRONG-TYPES]
- A newtype guards its invariants. It has at least one fallible constructor, and conversions from the weaker type go through `TryFrom`/`FromStr`, never an infallible `From`. Name the constructors by Google's rules. [M-STRONG-TYPES-GUARD]
- Avoid `static` and thread-locals when one consistent value matters for correctness. Two semver-incompatible versions of a crate in one build each get their own copy. Statics used only for speed are fine. [M-AVOID-STATICS]

## 5. Testability (libs/resilience)

- Code that touches I/O, clocks, randomness or the environment can be mocked. Use no ad-hoc `fs::read("foo.txt")` and no hidden `Io::default()`. The pattern is `Foo::new(io)` for real use and `Foo::new_mocked() -> (Foo, MockCtrl)` for tests, over a private enum with a `Native` variant and a `#[cfg(feature = "test-util")] Mocked` variant. Bound or chunk unbounded memory use. [M-MOCKABLE-SYSCALLS]
- Test-only code (mocks, fake data, safety overrides, inspecting sensitive data) goes behind a single feature named `test-util`. [M-TEST-UTIL]
- Tests that use only the public API go in `tests/`, not a `mod tests` in `src/`. When both would work, write an integration test. [M-INTEGRATION-TESTS]
- A test checks properties, never ground truth. Don't restate a constant or mirror the implementation; assert, say, that values are evenly spaced or monotonic. [M-TAUTOLOGICAL-TESTS]

## 6. Building and features (libs/building)

- A library builds on every Tier 1 platform with only `cargo` and `rustc` (and the default C toolchain). It needs no extra tools or environment variables. Generate artifacts before publishing, and gate platform dependencies with `cfg` or features. [M-OOBE]
- A `-sys` crate builds its native code from `build.rs` with the `cc` crate, never a Makefile. It embeds sources with their Git URL and hash, ships pre-generated `bindgen` output, makes external tools optional, and supports static and dynamic (`libloading`) linking. [M-SYS-CRATES]
- Features are additive. There is no `no-std` feature (use a `std` feature instead), no feature removes a public item, and no feature depends on another being enabled by hand. New enum variants behind a feature need `#[non_exhaustive]`. [M-FEATURES-ADDITIVE]

## 7. Macro crates (macros)

Google's [G#macros] decides whether to write a macro at all. These rules cover how to build one.

- A macro never lies about the item it expands: no turning a struct into an enum, no changing a signature, no adding or removing `async`. [M-MACROS-DONT-LIE]
- Split proc macros into `foo` (the main crate), `foo_proc` (a thin `proc-macro = true` shim) and `foo_proc_impl` (the logic). Test the impl crate with `insta` snapshots and the main crate with `trybuild` UI tests. [M-MACRO-MAIN-CRATE], [M-PROC-IMPL]
- Pin a supporting proc-macro crate exactly (`foo_proc = "=1.2.3"`) and release both crates together at the same version. Proc-macro libraries used on their own are exempt. [M-MACRO-VERSION-PIN]
- Macros reach third-party items through `#[doc(hidden)] pub mod _private { pub use ::bar::Bar; }` and emit `::foo::_private::Bar` paths. [M-MACRO-HELPERS]
- A proc macro generates no hidden or implied public items. A root crate may use the namespace trick (`fn foo` plus `struct foo`) for request handlers or FFI. [M-PROC-IMPLIED-ITEMS]

## 8. Applications (apps)

- Use mimalloc: `mimalloc = "0.1"` plus `#[global_allocator] static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;`. Microsoft reports up to 25% benchmark gains. Measure before and after. [M-MIMALLOC-APPS]
- An application may use one app error type (`anyhow`, `eyre` or `ohno::AppError`) instead of defining its own. Don't mix two of them. Libraries never do this. [M-APP-ERROR]
- x86-64 server applications set `rustflags = ["-C", "target-cpu=x86-64-v3"]` in `.cargo/config.toml`, under `[target.x86_64-unknown-linux-gnu]` and `[target.x86_64-pc-windows-msvc]`. Not for libraries, and not for apps that ship to unknown hardware. [M-TARGET-CPU]

## 9. FFI (ffi)

- Business logic lives in a safe, idiomatic core crate `foo`. A glue crate `foo-ffi` only translates, with `#[unsafe(no_mangle)] pub unsafe extern "C"` functions and `#[repr(C)]` types. [M-FFI-TRANSLATES]
- Name a crate that calls a C library `-sys` (or `-sys2`), and one that exports C-style items `-ffi`. [M-FFI-NAMING]
- Across a DLL boundary, share only portable data: `#[repr(C)]` types, no statics, thread-locals or `TypeId`, and no pointers into non-portable data. Rust allocations (`String`, `Box`) and runtime statics (`tokio`, `log`) never cross. [M-ISOLATE-DLL-STATE]

## 10. Soundness (correctness)

Google covers when to write `unsafe` and how to justify it. Microsoft adds:

- All code is sound. A safe function that can cause UB is never acceptable, however unlikely the misuse. The soundness boundary is the module; if you can't make it sound, expose an `unsafe fn` instead. [M-UNSOUND]
- Mark a function `unsafe` only if misuse means undefined behavior. A dangerous but sound operation, such as deleting a database, stays safe. [M-UNSAFE-IMPLIES-UB]
- Every `unsafe` passes Miri. A novel unsafe abstraction gets adversarial tests, and if a user closure panics inside it, it poisons its state rather than leaving it half-updated. [M-UNSAFE]

## 11. Performance (performance)

- Optimize for throughput: items per CPU cycle. Offer batch APIs, never spin hot, and share state only when sharing is cheaper than recomputing. [M-THROUGHPUT]
- Find the hot path early and benchmark it with `criterion` or `divan`. Set `[profile.bench] debug = 1` for profiling, profile regularly, and document known hot spots. [M-HOTPATH]
- A long-running async task yields (`yield_now().await`) every 10–100 μs of CPU work. When the work per step is unpredictable, check a budget such as `has_budget_remaining()`. [M-YIELD-POINTS]
- Reuse allocations. APIs take a `&mut` buffer (`get_in(id, &mut value)`), loops `clear()` and refill, and deep call stacks use an arena. [M-MEM-REUSE]
- Avoid stacked indirection in hot types (`Arc` inside `Arc`). Lift often-read fields, such as an `enabled: bool`, into the outer struct. [M-AVOID-INDIRECTION]
- Store frequent, immutable, internal sequences as `Box<[T]>`, `Box<str>` or `Arc<str>`. That saves a third of the `Vec` handle. [M-BOX-DST]
- Call `shrink_to_fit()` on a long-lived `Vec` or `String` built without a known size. [M-SHRINK-TO-FIT]
- Hash trusted internal keys with `foldhash` or `FxHash`. Keep the default SipHash for untrusted input, which protects against HashDoS. [M-FAST-HASHER]
- Create collections with `with_capacity` when the size is known, and prefer `collect()` to a `push` loop. [M-INITIAL-CAPACITY]
- Track the size of hot futures with `size_of_val` in a test. Shrink them by passing smaller arguments, holding fewer values across `.await`, returning `impl Future`, or using `Either`. [M-ASYNC-STACK-SIZE]

## 12. Workspace and project (project)

- Shared settings come from the workspace `Cargo.toml`: package metadata, `[workspace.dependencies]` (with `default-features = false`) and `[workspace.lints]`. [M-CARGO-WORKSPACE]
- Every crate is a workspace member. Internal dependencies are declared as `sibling.workspace = true`, with their version in `[workspace.dependencies]`. [M-CRATES-IN-WORKSPACE]
- All crates are siblings in one folder: a `crates/` directory, or the workspace root for a handful. Never nest a crate inside another crate or its `src/`. [M-CRATES-FLAT-FOLDER]
- New crates use the latest edition, 2024 or later. [M-LATEST-EDITION]
- Set an MSRV when a crate is created and keep it a few releases behind stable. Raising it is a minor version bump. [M-MSRV]

## 13. Docs (docs)

These add to Google's `missing_docs` and `missing_panics_doc`.

- The first doc sentence fits on one line, at most about 15 words. It is what module summaries show. `too_long_first_doc_paragraph` checks part of this. [M-FIRST-DOC-SENTENCE]
- Every public library module has `//!` docs: what it holds, when to use it, examples, side effects, and implementation notes that matter to users. [M-MODULE-DOCS]
- Public item docs use the canonical sections: summary, details, `# Examples`, `# Errors`, `# Panics`, `# Safety`, `# Abort`. No `# Parameters` lists. [M-CANONICAL-DOCS]
- Put `#[doc(inline)]` on `pub use` re-exports of your own crate's items. Not on std or third-party items. [M-DOC-INLINE]

## 14. Code written by agents (ai)

- A public item is reachable through one path only. Don't both `pub use db::Connection` and keep `db` public. A `pub(crate)` module with one `pub use` is fine, and macro `_private` modules are exempt. [M-SINGLE-ITEM-PATH]
- Crate and module docs hold no design journal and no table reporting which guidelines the code follows. A design-principles section in a README is fine. [M-NO-META-DESIGN-DOCUMENTATION]
- Rust code solves Rust problems. Don't port C#, Java or Python patterns one-to-one (no `throw_if_null`); separate the domain logic from the source language's idioms. [M-RUST-SHAPED]

## Left out

These Microsoft rules overlap Google (follow google-rust-style) or clash with it (Google wins):

| Microsoft | Why it is out |
|---|---|
| [M-SHORT-NAMES] abbreviations, at most two words | Clashes: Google spells words out ([G#avoid-abbreviations]) |
| [M-ERRORS-CANONICAL-STRUCTS] error struct with `Backtrace`, hidden kind, `is_xxx()` | Clashes: Google wants `Copy` error types with a payload only when the caller needs it |
| [M-SERVICES-CLONE] `Arc<Inner>` services | Clashes: Google wants unique ownership first ([G#avoid-rc-arc]) |
| [M-PANIC-IS-STOP] `unwrap()` on a lock result | Clashes: Google wants `expect` over `unwrap`, also on locks (both agree a poisoned lock panics) |
| [M-PANIC-CONTINUATION] per-request `catch_unwind` with a restart | Clashes: Google prohibits `catch_unwind` except a defense-in-depth wrapper |
| [M-PANIC-MESSAGE] every panic carries a message | Clashes: Google adds a message only when it says more than the condition ([G#assertion-context]) |
| [M-NO-GLOB-REEXPORTS] | Clashes: Google allows `pub use sub::*` ([G#glob-imports]) |
| [M-IMPL-ASREF], `impl Into<FooDeps>` in [M-INIT-BUILDER] | Clashes: Google keeps conversion parameters to library APIs where ergonomics are paramount ([G#accepting-into]) |
| `pedantic`, `cargo`, `redundant_type_annotations`, `if_then_some_else_none`, `map_err_ignore` in [M-STATIC-VERIFICATION] | See section 1 |
| [M-AVOID-WRAPPERS], [M-NO-PRELUDE], [M-PANIC-ON-BUG], [M-MACRO-LAST-RESORT], [M-EXAMPLE-OVER-PROC], [M-LINT-OVERRIDE-EXPECT], [M-UNSAFE] (when to use it) | Overlap: Google already says the same |
| [M-UPSTREAM-GUIDELINES], [M-DESIGN-FOR-AI] | Too general to act on: they point at other guides or restate good practice |

`G#anchor` means `https://google.github.io/styleguide/rustguide.html#anchor`, as in google-rust-style.
