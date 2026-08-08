.PHONY: fmt lint test

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

test: # Run CounterHarness smoke test with ripfuzz
	@echo "Clean foundry build artifacts"
	@forge clean
	@echo "Build foundry project"
	@forge build
	@echo "Clean ripfuzz corpus"
	@rm -rf .ripfuzz/corpus
	@echo "Run CounterHarness smoke test"
	@ripfuzz run CounterHarness \
		--force \
		--max-runs 100 \
		--threads 2 \
		--timeout 30 \
		--max-calls 20 \
		--seed 1 \
		--log-level warn
