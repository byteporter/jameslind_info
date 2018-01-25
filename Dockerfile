FROM golang:1.9.2-alpine3.7 AS BuildResumeApp
LABEL MAINTAINER="james@byteporter.com"

ENV CGO_ENABLED=0

RUN set -x \
    && apk add --no-cache --virtual .build-deps git

WORKDIR /go/src/github.com/byteporter/resume

COPY resume /go/src/github.com/byteporter/resume

RUN set -x \
    && go-wrapper download \
    && go-wrapper install -a

FROM scratch

EXPOSE 80

COPY --from=BuildResumeApp /go/bin/resume /go/bin/resume

ENTRYPOINT [ "/go/bin/resume" ]