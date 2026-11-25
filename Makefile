SHELL := /bin/bash

STORE := Chinook/Chinook/Resources/Chinook.store
SEED_DB := ChinookModels/SeedData/chinook.sqlite

$(STORE):
	swift run --package-path ChinookModels chinook-store-export \
		"$(abspath $(SEED_DB))" \
		"$(abspath $@)"

.PHONY: init
init: $(STORE)

.PHONY: test
test:
	@set -o pipefail; xcodebuild test \
		-project Chinook/Chinook.xcodeproj \
		-scheme Chinook \
		-destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.2' \
		'-only-testing:ChinookTests/ChinookTests/albumDetail()' \
		| xcbeautify
