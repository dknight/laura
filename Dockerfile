# Change luarocks version, public tags can be found here
# https://hub.docker.com/r/nickblah/lua/
FROM nickblah/lua:5.4-luarocks-alpine

RUN luarocks install laura

# Change workdir if you use any different than /app.
WORKDIR /app

ENTRYPOINT ["laura"]