.PHONY: fmt lint test exec

HARNESSES := \
	CounterHarness \
	CheatcodesHarness \
	GetEnvHarness \
	AddressHarness \
	ActorsHarness \
	BoundHarness \
	LoggingHarness \
	AssertionsHarness \
	TokensHarness \
	ForkHarness \
	MultiForkHarness

TESTS := \
	ExampleInvariantTest

SCRIPTS := \
	ExampleScript

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

test: # Run example smoke tests with ripfuzz
	@echo "Clean ripfuzz corpus"
	@rm -rf .ripfuzz/corpus
	@for test in $(TESTS); do \
		echo "Run $$test smoke test"; \
		ripfuzz test examples/$$test.sol \
			--max-fuzz-runs 100 \
			--threads 2 \
			--timeout 60 \
			--max-calls 20 \
			--log-level warn \
			|| exit 1; \
	done

exec: # Run example script smoke tests with ripfuzz
	@echo "Clean ripfuzz corpus"
	@rm -rf .ripfuzz/corpus
	@for script in $(SCRIPTS); do \
		echo "Run $$script smoke test"; \
		ripfuzz exec examples/$$script.sol \
			--log-level warn \
			|| exit 1; \
	done
