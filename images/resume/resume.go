package main

import (
	"log"
	"net/http"

	"fmt"

	"github.com/gorilla/mux"
	"github.com/russross/blackfriday"
)

type Resume struct {
	Body string `json:"body,omitempty`
}

func GetResumeEndpoint(w http.ResponseWriter, req *http.Request) {
	var output = blackfriday.MarkdownCommon([]byte(`#My Resume`))
	// w.Header().Set("Content-Type", "text/html")
	fmt.Fprint(w, output)
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/resume", GetResumeEndpoint).Methods("GET")
	log.Fatal(http.ListenAndServe(":8080", router))
}
