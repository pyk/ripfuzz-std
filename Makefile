.PHONY: fmt
fmt: # Run formatter
	@echo "Run foundry formatter"
	@forge fmt
	@echo "Run markdown formatter"
	@uvx --from panache-cli==2.61.0 panache format .
