package main

import (
  "fmt"
  "net/http"
)

const (
  port = ":80"
)

var calls = 0

func HelloWorld(w http.ResponseWriter, r *http.Request) {
  calls++
  fmt.Fprintf(w, "<h1>GO - Исламов Андрей Валерьевич</h1> You have called me %d times.\n", calls)
}

func init() {
  fmt.Printf("Started server at http://localhost%v.\n", port)
  http.HandleFunc("/", HelloWorld)
  http.ListenAndServe(port, nil)
}

func main() {}
