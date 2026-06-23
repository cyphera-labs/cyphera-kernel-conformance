# Compile a dynamically-linked glibc hello and stage /out/{hello, ld-linux-x86-64.so.2, libc.so.6}.
FROM debian:bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev
COPY hello.c /tmp/hello.c
RUN gcc -O2 -o /tmp/hello /tmp/hello.c \
 && mkdir -p /out \
 && cp /tmp/hello                              /out/hello \
 && cp /lib64/ld-linux-x86-64.so.2             /out/ld-linux-x86-64.so.2 \
 && cp /lib/x86_64-linux-gnu/libc.so.6         /out/libc.so.6 \
 && ls -la /out

FROM debian:bookworm-slim
COPY --from=build /out /out
