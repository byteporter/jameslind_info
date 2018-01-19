FROM golang:1.9.2-alpine3.7 AS BuildResumeApp
LABEL MAINTAINER="james@byteporter.com"

RUN set -x \
    && apk add --no-cache --virtual .build-deps git

WORKDIR /go/src/github.com/byteporter/resume

COPY resume /go/src/github.com/byteporter/resume

RUN set -x \
    && go-wrapper download \
    && go-wrapper install

FROM alpine:3.7

EXPOSE 80

COPY --from=BuildResumeApp /go/bin/resume /bin/resume

ENTRYPOINT [ "/bin/resume" ]