---
applyTo: "**/*.java"
---

# Available libraries (already on the classpath)

Generate the raw list per repo, then condense into the table below. Keep it short: library, version, what to reach for it for.
    mvn dependency:list -Dscope=compile -DoutputFile=deps.txt
    ./gradlew dependencies --configuration runtimeClasspath

Rule: if a capability below exists, use it. Do not hand-roll it.

| Need | Use | Notes |
|---|---|---|
| Partition a list into batches | `Lists.partition(list, 500)` (Guava) or `ListUtils.partition` (Commons Collections) | returns views, not copies |
| Null-safe / blank string checks | `StringUtils` (Commons Lang3) | `isBlank`, `defaultIfBlank`, `substringBetween` |
| Argument / state validation | `Objects.requireNonNull` (JDK), `Preconditions` (Guava), `Assert` (Spring) | pick the one already used in the module |
| Collection null/empty checks | `CollectionUtils` (Spring or Commons) | |
| Multi-value maps, bi-maps, sets ops | Guava `Multimap`, `BiMap`, `Sets.difference/intersection` | |
| Retry and backoff | Resilience4j / Spring Retry | never hand-roll sleep loops |
| JSON | Jackson `ObjectMapper` | reuse the configured Spring bean; do not construct new ones |
| HTTP calls | `RestClient` / `WebClient` (Spring) | always set timeouts |
| Hashing, encoding, IO streams | Guava `Hashing`/`Files`, Commons `Codec`/`IOUtils`, JDK `HexFormat`, `Base64` | |
| Date ranges, business days | internal calendar service | never hand-roll weekend/holiday logic |
| Equality, hashCode, toString | records, or Lombok if the module already uses it | follow the module |
| Assertions in tests | AssertJ | |

## Repo-specific
Fill in: internal platform libraries, shared utils modules, and the house wrappers that must be used instead of the raw library.

| Need | Use | Notes |
|---|---|---|
|  |  |  |

## Not available
List anything explicitly banned or not in the approved artifact repository, so it is not suggested.
