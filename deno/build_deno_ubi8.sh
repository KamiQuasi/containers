#!/usr/bin/env bash
# build_deno_ubi8.sh
#
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal)
mountpoint=$(buildah mount $ctr)
mkdir $mountpoint/var/www
buildah config --workingdir /var/www $ctr
buildah copy $ctr ./index.html /var/www
buildah config --env DENO_INSTALL=/usr/local $ctr
buildah config --env PATH=$PATH:/usr/local/bin $ctr
buildah run --isolation rootless $ctr /bin/sh -c "microdnf update; \
microdnf -y install unzip; \
curl -fsSL https://deno.land/x/install/install.sh | sh; \
microdnf clean all;"
buildah config --entrypoint "deno run --allow-net --allow-read https://deno.land/std@0.81.0/http/file_server.ts -p 8080" $ctr
buildah config --port 8080 $ctr
buildah commit --squash $ctr deno-app
buildah unmount $ctr
buildah rm $ctr