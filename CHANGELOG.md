## [1.0.0]

* Null safety migration

## [0.0.4]

* API Refactors
    - StoreKeeper.update changes to StoreKeeper.listen
    - StoreKeeper.getStreamOf changes to StoreKeeper.streamOf
    - UpdateOn changes to RebuildOn
    - APIs works with the Type instead of hashCode
    - Removed HTTP side effects. Will be available as plugin.
* New helper widget - NotifyOn
* Added support for Interceptors
* More docs and tests, effective_dart

## [0.0.3]

* Simplified internals with unified event stream
* StoreKeeper.getStreamOf(...) returns stream directly
* Removed Inventory class. Merged that with StoreKeeper.

## [0.0.2]

* Added support for HTTP interceptors
* Added support for HTTP timeouts
* Bug fixes

## [0.0.1]

* Initial release with basic features
