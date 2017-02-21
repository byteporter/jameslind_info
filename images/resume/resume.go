package main

import (
	"io/ioutil"
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
	b, _ := ioutil.ReadFile(`resume.md`)
	var output = blackfriday.MarkdownCommon(b)
	// n := bytes.IndexByte(output, 0)
	// w.Header().Set("Content-Type", "text/html")
	fmt.Fprint(w, string(output))
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/resume", GetResumeEndpoint).Methods("GET")
	log.Fatal(http.ListenAndServe(":8080", router))
}
