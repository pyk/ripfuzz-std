.PHONY: fmt test exec max

TESTS := \
	ExampleInvariantTest

SCRIPTS := \
	ExampleDeal \
	ExampleScript

MAXES := \
	ExampleMax

fmt: # Run markdown formatter
	@echo "Run markdown formatter"
	@uvx --from panache-cli==2.61.0 panache format .

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

max: # Run example max smoke tests with ripfuzz
	@echo "Clean ripfuzz corpus"
	@rm -rf .ripfuzz/corpus
	@for max in $(MAXES); do \
		echo "Run $$max smoke test"; \
		ripfuzz max examples/$$max.sol \
			--max-fuzz-runs 100 \
			--threads 2 \
			--timeout 60 \
			--max-calls 20 \
			--log-level warn \
			|| exit 1; \
	done
