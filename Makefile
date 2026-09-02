.PHONY: fmt lint test

HARNESSES := \
	CounterHarness \
	CheatcodesHarness \
	GetEnvHarness \
	AddressHarness \
	ActorsHarness \
	BoundHarness \
	LoggingHarness \
	AssertionsHarness \
	ExampleInvariantTest \
	TokensHarness \
	ForkHarness \
	MultiForkHarness

fmt: # Run formatters
	@echo "Run foundry formatter"
	@forge fmt
	@echo "Run markdown formatter"
	@uvx --from panache-cli==2.61.0 panache format .

lint: # Check format and compile Solidity sources
	@echo "Check foundry formatter"
	@forge fmt --check src/ examples/
	@echo "Compile Solidity sources"
	@forge compile --skip script

test: # Run example harness smoke tests with ripfuzz
	@echo "Clean foundry build artifacts"
	@forge clean
	@echo "Build foundry project"
	@forge build
	@echo "Clean ripfuzz corpus"
	@rm -rf .ripfuzz/corpus
	@for harness in $(HARNESSES); do \
		echo "Run $$harness smoke test"; \
		ripfuzz test examples/$$harness.sol \
			--max-fuzz-runs 100 \
			--threads 2 \
			--timeout 60 \
			--max-calls 20 \
			--log-level warn \
			|| exit 1; \
	done
