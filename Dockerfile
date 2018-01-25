FROM golang:1.9.2-alpine3.7 AS BuildResumeApp
LABEL MAINTAINER="james@byteporter.com"

# ENV CGO_ENABLED=0

RUN set -x \
    && apk add --no-cache --virtual .build-deps git

WORKDIR /go/src/github.com/byteporter/resume

COPY resume /go/src/github.com/byteporter/resume

# go-wrapper install needs '-a' option to rebuild libraries statically too if necessary
RUN set -x \
    && go-wrapper download \
    && go-wrapper install

FROM alpine:3.7

EXPOSE 80

COPY --from=BuildResumeApp /go/bin/resume /go/bin/resume

ENTRYPOINT [ "/go/bin/resume" ]