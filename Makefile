.PHONY: build run clean test

build:
	go build -o ./bin/smoke-test-server ./main.go