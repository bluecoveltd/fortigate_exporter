# Build using the minimum supported Golang version (match go.mod)
# docker buildx build . -t bluecove2.azurecr.io/fortigate_exporter:1.25.0_1
FROM golang:1.21 as builder

WORKDIR /build

COPY . .
RUN go get -v -t -d ./...
RUN make build

FROM alpine:3.20.0
WORKDIR /opt/fortigate_exporter

COPY --from=builder /build/target/fortigate-exporter .
COPY --from=builder /etc/ssl/certs/ca-certificates.crt .
ENV SSL_CERT_DIR=/opt/fortigate_exporter

EXPOSE 9710
ENTRYPOINT ["./fortigate-exporter"]
CMD ["-auth-file", "/config/fortigate-key.yaml"]
