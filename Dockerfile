FROM alpine:3.8
LABEL MAINTAINER="james@byteporter.com"

EXPOSE 80

COPY resume/output/resume /go/bin/resume
COPY resume/output/web/. /usr/share/resume

ENTRYPOINT [ "/go/bin/resume" ]