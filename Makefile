BINARY_NAME=main
GOOS_NFSN=freebsd
GOARCH_NFSN=amd64

.PHONY: build build-nfsn test scripts clean

# Build for native architecture
build:
	go mod tidy
	go build -o $(BINARY_NAME) main.go

# Build for NearlyFreeSpeech.NET (FreeBSD amd64)
build-nfsn:
	go mod tidy
	GOOS=$(GOOS_NFSN) GOARCH=$(GOARCH_NFSN) go build -v -o $(BINARY_NAME)_nfsn ./...

# Run tests
test:
	go mod tidy
	go test -v ./...

# Generate run script with bearer token
scripts-nfsn:
	@if [ -z "$$BEARER_TOKEN" ]; then \
		echo "Error: BEARER_TOKEN environment variable is not set"; \
		exit 1; \
	fi
	@echo '#!/bin/sh' > run.sh
	@echo 'set -eou pipefail' >> run.sh
	@echo 'export BEARER_TOKEN='\"$$BEARER_TOKEN\" >> run.sh
	@echo '/home/protected/$(BINARY_NAME)_nfsn' >> run.sh
	@chmod +x run.sh

# Clean built binaries and scripts
clean:
	rm -f $(BINARY_NAME) $(BINARY_NAME)_nfsn run.sh