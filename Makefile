NODEJS = $(if $(shell test -f /usr/bin/nodejs && echo "true"),nodejs,node)
TEST_CASES = $(shell find test/ -name "*.test.coffee")

all: test

test:
	$(NODEJS) ./node_modules/nodeunit/bin/nodeunit $(TEST_CASES)

.PHONY: test all
