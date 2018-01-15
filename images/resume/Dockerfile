FROM golang:latest

EXPOSE 8080

WORKDIR /go/src/app
COPY ../../app /go/src/app

RUN go-wrapper download   # "go get -d -v ./..."
RUN go-wrapper install    # "go install -v ./..."

CMD ["go-wrapper", "run"] # ["app"]