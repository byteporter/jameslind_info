package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"html/template"

	"github.com/gorilla/mux"
	"github.com/russross/blackfriday"
)

type justFilesFilesystem struct {
	fs http.FileSystem
}

func (fs justFilesFilesystem) Open(name string) (http.File, error) {
	f, err := fs.fs.Open(name)
	if err != nil {
		return nil, err
	}
	return neuteredReaddirFile{f}, nil
}

type neuteredReaddirFile struct {
	http.File
}

func (f neuteredReaddirFile) Readdir(count int) ([]os.FileInfo, error) {
	return nil, nil
}

type Resume struct {
	Body string `json:"body,omitempty`
}

func GetResumeEndpoint(w http.ResponseWriter, req *http.Request) {
	b, _ := ioutil.ReadFile(`resume.md`)
	var output = blackfriday.MarkdownCommon(b)
	t, _ := template.ParseFiles("templates/resume.gohtml")
	rawHtml := template.HTML(output)
	t.Execute(w, rawHtml)
	// fmt.Fprintf(w, "%s", output)

}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/resume", GetResumeEndpoint).Methods("GET")
	router.PathPrefix("/resources/").Handler(http.StripPrefix("/resources/", http.FileServer(http.Dir("resources"))))
	http.Handle("/resources/", router)
	log.Fatal(http.ListenAndServe(":8080", router))
	// fs := justFilesFilesystem{http.Dir("resources/")}
	// router.Handle("/resources/", http.StripPrefix("/resources/", http.FileServer(fs)))
}
