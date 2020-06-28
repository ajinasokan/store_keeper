
.PHONY: doc
doc:
	dartdoc --exclude 'dart:async,dart:collection,dart:convert,dart:core,dart:developer,dart:io,dart:isolate,dart:math,dart:typed_data,dart,dart:ffi,dart:html,dart:js,dart:ui,dart:js_util'

.PHONY: serve
serve:
	indexof doc/api