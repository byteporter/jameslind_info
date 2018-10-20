FROM alpine:3.8
LABEL MAINTAINER="james@byteporter.com"

EXPOSE 80

ADD resume/resume-build-output.tar.gz /

WORKDIR /usr/share/resume/
ENTRYPOINT [ "/go/bin/resume" ]
