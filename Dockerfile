FROM debian:stretch-slim

RUN useradd -m godot

WORKDIR /home/godot

COPY --chown=godot game/export/ .

RUN ldconfig `pwd`

USER godot

ENTRYPOINT ./server
