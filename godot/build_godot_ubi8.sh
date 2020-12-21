#!/usr/bin/env bash
# build_godot_ubi8.sh
#
godotver='3.2.3'
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal)
#mountpoint=$(buildah mount $ctr)
#mkdir $mountpoint/var/www
buildah config --workingdir /usr/bin $ctr
buildah config --env PATH=$PATH:/usr/bin $ctr
buildah copy $ctr ../../games/summit2019 /usr/local/games/
buildah run --isolation rootless $ctr /bin/sh -c "curl -sSL https://downloads.tuxfamily.org/godotengine/$godotver/Godot_v$godotver-stable_linux_headless.64.zip | tar -xf - -C /usr/bin/; \
mv Godot_v$godotver-stable_linux_headless.64 godot"
buildah config --entrypoint "deno run --allow-net --allow-read https://deno.land/std@0.81.0/http/file_server.ts -p 8080" $ctr
buildah config --port 8080 $ctr
buildah commit --squash $ctr godot-app
buildah unmount $ctr
buildah rm $ctr