FROM ariel/dev:base

ENV DEBIAN_FRONTEND noninteractive

# packages
RUN apt-get install -y puppet puppetmaster puppetmaster-common rails libsqlite3-ruby libldap-ruby1.8 puppet-lint cron

# get the wmf puppet repo
RUN mkdir -p /var/lib/git/operations && mkdir -p /var/lib/git/labs && apt-get install -y git
RUN cd /var/lib/git/operations && git clone https://gerrit.wikimedia.org/r/operations/puppet.git

# add the wmf apt repo to our sources lists
RUN echo 'deb http://apt.wikimedia.org/wikimedia precise-wikimedia main universe non-free' > /etc/apt/sources.list.d/wikimedia-precise.list
RUN echo 'deb-src http://apt.wikimedia.org/wikimedia precise-wikimedia main universe non-free' >> /etc/apt/sources.list.d/wikimedia-precise.list
RUN echo '-----BEGIN PGP PUBLIC KEY BLOCK-----\n\
Version: GnuPG v1\n\
\n\
mQGiBEUtBY8RBACJTZdWEBZHlibArWM1HrX5rcPCb+o2nmeTfNrtMpmVbkmi9vBE\n\
VmIDnjc+VQlJNoiBOKMhAhRSO0rIwEbOTewiQSPERfsClGpv0ikb3kQVFls5HpfZ\n\
49u9EAERRez+P2VJUH7CBmigKdxtKRGM5aLI+eOLUl+lZUn4NU6BsQOUGwCgtLiL\n\
I+8DSNkoiV40UR3uFsS9KLMD/30Lth9A9JgwrDTFl8rlNxq3Eluulv0+2MYoDutW\n\
2p384vJ8Vil+x1GPzZXT1NVHCPdJMXqfnUl33XkPJEFSJ3B1WhwU3muItPoM+GKM\n\
cnJMn2rYJa6Fae7UZy8iRJwSuqSg4mGNa900m/izyYoijJzl1u4HtZhbV++lgubO\n\
j+YfA/4sz68H/ZQZwG+d8X/xTgZ3+9qekqGFgxdGTICtiD7IRPPaQ7EUWOBml6tn\n\
SHfd0TBkCKtfFkr6+rA3ZJ5pyo3OwO2yUAvlBOPeaX4ZKTl7+8lG9kqqGIBm/iZy\n\
bHC75DF506Zm4IiesAXRmRqfB8gReOHEJybZkaCg8FZqhdGErLQ8V2lraW1lZGlh\n\
IEFyY2hpdmUgQXV0b21hdGljIFNpZ25pbmcgS2V5IDxyb290QHdpa2ltZWRpYS5v\n\
cmc+iF8EExECACAFAkUtBY8CGwMGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRAJ\n\
29n5P2zUSmaGAJjipA+xkWInJJHCCcoJrf7rBzqEAJ9OEsJuxbBOvOJBovwpWtNh\n\
goMcubkCDQRFLQWdEAgAvEAe6PnzhGdOC3ZYIeJalQyBEelRZiEdzjtdojTNEf29\n\
6J75O8QqjQt/pyOZ9w/DCiy81dym3GlXeS61tcfNdSBMXqGtgXAskLV1djz0U7SU\n\
89MiwjrSiYhYRYNSQcrshVDjzpHkj8HY0gwNyN5yZ1xnZ9/WG46Kay6quHQbfKn7\n\
Egxs6ONJJaW7H1MM2cPzsJuzk1aXq4PJOFHgDo9J2j+nGVgk8XdGqgk5t0we69Oh\n\
YXlxUTjgOE+XMxk4PEOFDjk0pTmxOUMP0b08dpvJf652O4jpnylBIiT9ZxRadENM\n\
zmeBT//sJJIleYDh2a1xeDDQwzRig1swFnfYeuEugwADBQf/b7xdqYrLZYqtJVLO\n\
fgh3HOJ605KNYlyreKj67x04fy8lIhrkp3wraVTN74+jObNhJTq3VesUoPPgJqRi\n\
sABCwbGQeKriz7NUAflBliVapPjSd7qD696zO+wQd03z8wJecdxAcmw89+8jyHWV\n\
bgSf3Thy0pfCDBOZL5ApDzPp/zveTAJJdl9xJ+kQA9g4kXIbqdsv0ytqfT56CAOC\n\
vBIJ7JuzIz8eKZ5LlPoGosU5C6TPwlHwfrh1ttD5/LdoSbcz1ThCM3Q9nasvmQjQ\n\
EGZteBiJH8UogRLTsqbJCtQM6aQL8J/+bWjSrmPdCp2z/dzFTgtga4DKcXiSYo+U\n\
JVwilYhJBBgRAgAJBQJFLQWdAhsMAAoJEAnb2fk/bNRK/HEAn0ud2S4zsHv4Ayzp\n\
QqdXQFnLYQ6mAJ9LlSuxDwXm+ln+7o++xUBMQCKJ7g==\n\
=XekF\n\
-----END PGP PUBLIC KEY BLOCK-----\n' > /root/wmf-key.pub
RUN apt-key add /root/wmf-key.pub

# this can't be done after the container is up, wants privs, so do it
# now in case anybody needs it

# fail docker doesn't permit it yet
#RUN mknod fuse c 10 229 -m 0660
ADD fuse.tar.gz /dev

RUN for f in templates files manifests modules; do rmdir "/etc/puppet/${f}"; ln -s "/var/lib/git/operations/puppet/${f}" "/etc/puppet/${f}"; done

RUN mv /etc/puppet/manifests/site.pp /etc/puppet/manifests/site.pp.not ; \
    echo  '$realm = "production"\n$site = "equiad"\n'> /var/lib/git/operations/puppet/manifests/site.pp ; \
    grep import /etc/puppet/manifests/site.pp.not |grep -v realm.pp >> /var/lib/git/operations/puppet/manifests/site.pp ;\
    echo '\n\nnode "containerid-here" {\n    $gid=500\n}' >>  /var/lib/git/operations/puppet/manifests/site.pp ; \
    mv /etc/puppet/manifests/decommissioning.pp /etc/puppet/manifests/decommissioning.pp.not ; \
    echo  '$decommissioned_servers = [\n]\n' > /etc/puppet/manifests/decommissioning.pp

RUN echo  '[files]\n  path /etc/puppet/files\n# allow 172.0.0.0/24\n  allow *\n\n' > /etc/puppet/fileserver.conf ; \
    echo  '[private]\n  path /etc/puppet/private/files\n# allow 172.0.0.0/24\n  allow *\n\n' >> /etc/puppet/fileserver.conf ; \
    echo  '[plugins]\n# allow 172.0.0.0/24\n  allow *\n\n' >> /etc/puppet/fileserver.conf

# this is intended for the master stanza
RUN echo 'modulepath = /etc/puppet/private/modules:/etc/puppet/modules' >> /etc/puppet/puppet.conf

# fixme don't know if this works heh
RUN HOSTNAME=`/bin/hostname` echo  '\n\n[agent]\nserver = '"$HOSTNAME"'\n' >> /etc/puppet/puppet.conf

RUN mkdir -p /var/lib/git/operations/private ; ln -s /var/lib/git/operations/private /etc/puppet/private ; \
    mkdir -p /etc/puppet/private/modules /etc/puppet/private/manifests /etc/puppet/private/files /etc/puppet/private/templates

ADD README.container /root

EXPOSE 22

CMD /usr/sbin/sshd -D

