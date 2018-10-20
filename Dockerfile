FROM alpine:3.8
LABEL MAINTAINER="james@byteporter.com"

EXPOSE 80

COPY resume/output/go/bin /go/bin
COPY resume/output/usr/share/resume /usr/share/resume

WORKDIR /usr/share/resume/
ENTRYPOINT [ "/go/bin/resume" ]
