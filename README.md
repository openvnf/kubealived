# Kubealived

[![License: Apache-2.0][Apache 2.0 Badge]][Apache 2.0]
[![GitHub Release Badge]][GitHub Releases]
[![Keepalived Badge]][Keepalived Release]

A [Docker] image and [Kubernetes] manifests for providing Kubernetes cluster
API high availability with use of [Keepalived]. The solution assigns a
Kubernetes master node a specified IP address, and if the node is down the
address automatically moves to another master node.

## Usage

A Keepalived process should run on all the master nodes of a Kubernetes cluster
thefore [DaemonSet] is used. Keepalived assigns a specified IP address to a
specified network interface. It also requires a password for internal usage, you
less likely to type it anywhere, so could be random.

The provided [Manifest] defines placeholders for this. They should be replaced
with actual values prior to deployment:

```
$ IP="<IP>"
$ IFACE="<IFACE>"
$ PASSWORD="$(openssl rand -base64 8)"
$ curl https://raw.githubusercontent.com/openvnf/kubealived/master/bundle.yaml | \
       sed -e "s/_IP_/$IP/" \
           -e "s/_IFACE_/$IFACE/" \
           -e "s/_PASSWORD_/$PASSWORD/" | kubectl create -f-
```

After deployment one of the master nodes should get the specified IP address on
the specified network interface. If this master node or the running on it pod
are gone, the IP address moves to another master node.

## Try With Docker

To try the image with Docker only, prepare Keepalived configuration file:

```
# keepalived.conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0 # replace with actual network interface
    virtual_router_id 1
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass DJCcWWJARj4= # can be generated with "openssl rand -base64 8"
    }
    virtual_ipaddress {
        10.9.8.10 # replace with needed IP address
    }
}
```

Run container:

```
$ docker run --name=kubealived --rm -d --cap-add=NET_ADMIN --net=host \
             -v $PWD/keepalived.conf:/etc/keepalived/keepalived.conf \
             quay.io/openvnf/kubealived -nl
```

Stop container:

```
$ docker stop kubealived
```

## License

Copyright 2018 Travelping GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

<!-- Links -->

[Docker]: https://docs.docker.com
[Manifest]: bundle.yaml
[DaemonSet]: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset
[Keepalived]: https://github.com/acassen/keepalived
[Kubernetes]: https://kubernetes.io

<!-- Badges -->

[Apache 2.0]: https://opensource.org/licenses/Apache-2.0
[Apache 2.0 Badge]: https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg?style=flat-square
[GitHub Releases]: https://github.com/openvnf/kubealived/releases
[GitHub Release Badge]: https://img.shields.io/github/release/openvnf/kubealived/all.svg?style=flat-square
[Keepalived Badge]: https://img.shields.io/badge/Keepalived-v2.0.10-eba935.svg?style=flat-square
[Keepalived Release]: https://github.com/acassen/keepalived/releases/tag/v2.0.10
