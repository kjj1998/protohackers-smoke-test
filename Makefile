.PHONY: build run clean test

build:
	go build -o ./bin/server ./main.go