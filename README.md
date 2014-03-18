docker-wmf-puppet
=================

docker file for wmf puppet testing

This Dockerfile is intended for folks who are testing wmf puppet changes.
I use it on my laptop and while clunky it mostly gets the job done.

See README.container for what to do after the image is created and
a first container is launched.

We could be nice about how we add the wmf repo gpg key instead of
having it hacked into the Dockerfile but meh.

The fuse device addition was strictly a workaround to shut up
gluster whining and I never did test that.  Generally if your
stuff needs mknods or other privileged functionality, I haven't
played with that.

