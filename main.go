package main

import (
	"bufio"
	"log"
	"net"
)

func main() {
	listener, err := net.Listen("tcp", ":8090")
	if err != nil {
		log.Fatal("Error listening:", err)
	}
	defer listener.Close()

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Println("Error accepting conn:", err)
			continue
		}

		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	scanner := bufio.NewScanner(conn)
	var line string

	for scanner.Scan() {
		line = scanner.Text()
		log.Printf("Scanned line: %s\n", line)
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Scan error: %v", err)
	}

	_, err := conn.Write([]byte(line))
	if err != nil {
		log.Printf("Server write error: %v", err)
	}
}
