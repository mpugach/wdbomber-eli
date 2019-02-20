FROM erlang:21.2-alpine

LABEL maintainer="Maksym Pugach <pugach.m@gmail.com>"

COPY wdbomber /wdbomber

ENTRYPOINT ["/wdbomber"]

CMD ["-h"]
