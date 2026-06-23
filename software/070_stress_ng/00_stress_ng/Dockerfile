# Build an Alpine + stress-ng rootfs tarball (alpine-stress.tar) with openrc wiring and the boot stressor service.
FROM alpine:3.20 AS build
RUN apk add --no-cache \
        openrc alpine-baselayout busybox-suid bash util-linux \
        ca-certificates \
        stress-ng

RUN rc-update add devfs sysinit \
 && rc-update add procfs sysinit \
 && rc-update add sysfs sysinit \
 && rc-update add hostname boot \
 && rc-update add bootmisc boot \
 && rc-update add killprocs shutdown \
 && rc-update add local default

COPY stress-ng.start /etc/local.d/zz-stress.start
RUN chmod +x /etc/local.d/zz-stress.start

RUN mkdir -p /tmp/etc-overrides \
 && echo cyphera > /tmp/etc-overrides/hostname \
 && printf '127.0.0.1\tlocalhost cyphera\n' > /tmp/etc-overrides/hosts

RUN mkdir -p /work-root /out \
 && cp -a /bin /etc /lib /sbin /usr /var /work-root/ \
 && (cp -a /root /work-root/ 2>/dev/null || mkdir -p /work-root/root) \
 && mkdir -p /work-root/proc /work-root/sys /work-root/dev \
             /work-root/tmp /work-root/run /work-root/mnt \
 && chmod 1777 /work-root/tmp \
 && cp /tmp/etc-overrides/hostname /work-root/etc/hostname \
 && cp /tmp/etc-overrides/hosts /work-root/etc/hosts \
 && rm -rf /work-root/var/cache/apk/* \
 && tar cf /out/alpine-stress.tar -C /work-root .

FROM alpine:3.20
COPY --from=build /out/alpine-stress.tar /alpine-stress.tar
# nosemgrep: dockerfile.security.missing-user.missing-user
CMD ["cp", "/alpine-stress.tar", "/out/alpine-stress.tar"]
