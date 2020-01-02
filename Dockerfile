# this is to build the image
FROM golang:alpine as build

WORKDIR /go/src/go-web-hello-world
ADD . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

CMD ["./go-web-hello-world"]

# this is to publish the image
FROM scratch AS prod

COPY --from=build /go/src/go-web-hello-world/go-web-hello-world .
CMD ["./go-web-hello-world"]
