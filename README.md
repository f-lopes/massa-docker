# Massa node & client running on Docker :whale:

[![CI](https://github.com/f-lopes/massa-docker/actions/workflows/main.yml/badge.svg)](https://github.com/f-lopes/massa-docker/actions/workflows/main.yml)

The current supported Massa version is `TEST.6.5`.

:information_source: [Massa repository](https://github.com/massalabs/massa/)

## Crafted using the best practices for containers

* [Container](https://github.com/GoogleContainerTools/container-structure-test) Structure tests
* [Trivy](https://github.com/aquasecurity/trivy#abstract): image vulnerabilities scanner
* [Dive](https://github.com/wagoodman/dive): image efficiency scanner
* [Distroless](https://github.com/GoogleContainerTools/distroless#why-should-i-use-distroless-images) runtime

## How to use

### Running a Massa node

```shell
docker run -d --name massa-node ghcr.io/f-lopes/massa-node:TEST.6.5
```

#### Inspect node logs
```shell
docker logs -f massa-node
```

### Staking rolls

Simply put your private key into a `staking_keys.json` file and mount its directory into the container (`/massa-node/config/`):
```shell
cat staking_keys.json
[
  "2excvw871qjhXzAtVu1C1f283fgasns35r9aP1wgU3M2v2ynnJ"
]
```

```shell
docker run -d --name massa-node -v /some/directory/:/massa-node/config/ ghcr.io/f-lopes/massa-node:TEST.6.5
```

If you don't have a private key yet, check this [section](#Generating-a-wallet).

### Launching Massa client

```shell
docker run --rm -it -v /massa-client-config-directory/:/massa-client/config/ ghcr.io/f-lopes/massa-client:TEST.6.5
```

#### Querying your node status

1. Get container private IP
```shell
NODE_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' massa-node)
```
2. Get node status using client
```shell
docker run --rm -it ghcr.io/f-lopes/massa-client:TEST.6.5 get_status --ip ${NODE_IP}
```

#### Generating a wallet

:warning: Running this command will generate a private key and create a `wallet.dat` file in the mounted host directory.
Make sure to back up this file and make it accessible to the client container whenever needed (ie. `wallet_info`, `buy_rolls`, etc.).

```shell
docker run --rm -it -v /config/directory/:/massa-client/config/ -v $(pwd):/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.6.5 wallet_generate_private_key -w /massa-client/wallet-directory/wallet.dat
```

#### Inspecting the generated wallet

:memo: Make sure to share and reference your `wallet.dat` file (`-v /host/wallet/directory/:/massa-client/wallet-directory/`) each time you want to execute wallet-related commands.

```shell
docker run --rm -it -v /config/directory/:/massa-client/config/ -v /host/wallet/directory/:/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.6.5 wallet_info -w /massa-client/wallet-directory/wallet.dat
```

#### Buying rolls

To buy rolls, you need:
- a wallet (see the previous [section](#Generating-a-wallet))
- a node (RPC) running & accessible (private API port open)

```shell
docker run --rm -it -v /host/wallet/directory/:/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.6.5 buy_rolls <your_address>  <roll count> <fee> -w /massa-client/wallet-directory/wallet.dat --ip ${NODE_IP}
```

:grey_question: See [Massa documentation](https://github.com/massalabs/massa/wiki/staking#buying-rolls) for more details.

:note:
You won't be able to SSH into these containers as they use a [distroless](https://github.com/GoogleContainerTools/distroless#why-should-i-use-distroless-images) base image.
:construction:
A specific tag will be available for debug needs.

## Feedback

Feel free to give any feedback in the [issues](https://github.com/f-lopes/massa-docker/issues) section.