FROM jlind/go-build-environment AS ApplicationBuilder

COPY resume/ /build/

WORKDIR /build/

RUN make resume

FROM jlind/pandoc-build-environment AS HardcopyBuilder

ENV INSTALL_DIR /usr/share/resume/
ENV BIN_DIR /go/bin/

COPY resume/ /build/
COPY --from=ApplicationBuilder /build/resume /build/

WORKDIR /build/

RUN make install

FROM alpine:3.8
LABEL MAINTAINER="james@byteporter.com"

EXPOSE 80

COPY --from=HardcopyBuilder /go/bin/resume /go/bin/resume
COPY --from=HardcopyBuilder /usr/share/resume/ /usr/share/

WORKDIR /usr/share/resume/
ENTRYPOINT [ "/go/bin/resume" ]