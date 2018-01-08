package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"html/template"

	"github.com/gorilla/handlers"
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

type resourceFileHandler struct {
	h http.Handler
}

type resumeHandler struct {
	h http.Handler
}

func (vh resourceFileHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Vary", "Accept-Encoding")
	w.Header().Set("Cache-Control", "max-age=2592000") //30 days
	vh.h.ServeHTTP(w, req)
}

func (rh resumeHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	b, _ := ioutil.ReadFile(`resume.md`)
	var output = blackfriday.MarkdownCommon(b)
	t, _ := template.ParseFiles("templates/resume.gohtml")
	w.Header().Set("Vary", "Accept-Encoding")
	t.Execute(w, template.HTML(output))
}

func main() {
	router := mux.NewRouter()
	rh := resumeHandler{}
	router.Handle("/", handlers.CompressHandler(rh)).Methods("GET")
	fs := justFilesFilesystem{http.Dir("resources/")}
	rfh := resourceFileHandler{http.StripPrefix("/resources/", http.FileServer(fs))}
	router.PathPrefix("/resources/").Handler(rfh)
	http.Handle("/resources/", router)
	log.Fatal(http.ListenAndServe(":8080", router))
}
