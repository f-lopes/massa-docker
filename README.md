# Massa node & client running on Docker :whale:

[![CI](https://github.com/f-lopes/massa-docker/actions/workflows/main.yml/badge.svg)](https://github.com/f-lopes/massa-docker/actions/workflows/main.yml)

The current supported Massa version is `TEST.7.0`.

:information_source: [Massa repository](https://github.com/massalabs/massa/)

## Crafted using the best practices for containers

* [Container](https://github.com/GoogleContainerTools/container-structure-test) Structure tests
* [Trivy](https://github.com/aquasecurity/trivy#abstract): image vulnerabilities scanner
* [Dive](https://github.com/wagoodman/dive): image efficiency scanner
* [Distroless](https://github.com/GoogleContainerTools/distroless#why-should-i-use-distroless-images) runtime

## How to use

### Running a Massa node

```shell
CONFIG_DIRECTORY=/massa/node/config/
docker run -d --name massa-node -v /massa-node-config-directory/:${CONFIG_DIRECTORY} -e MASSA_CONFIG_PATH=${CONFIG_DIRECTORY}config.toml ghcr.io/f-lopes/massa-node:TEST.7.0
```

#### Inspect node logs
```shell
docker logs -f massa-node
```

### Using Massa client

```shell
docker run --rm -it -v /massa-client-config-directory/:/massa-client/config/ ghcr.io/f-lopes/massa-client:TEST.7.0
```

#### Querying your node status

1. Get container private IP
```shell
NODE_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' massa-node)
```
2. Get node status using client
```shell
docker run --rm -it ghcr.io/f-lopes/massa-client:TEST.7.0 get_status --ip ${NODE_IP}
```

### Staking rolls

```shell
docker run --rm -it -v /node-client-config-directory/:/massa-client/config/ -v /node-client-config-directory/:/massa-client/wallet-directory/ -w /massa-client/wallet-directory ghcr.io/f-lopes/massa-client:TEST.7.0 buy_rolls <wallet_address> <roll_count> <fee> --ip ${NODE_IP}
```

```shell
docker run --rm -it -v /node-client-config-directory/:/massa-client/config/ -v /node-client-config-directory/:/massa-client/wallet-directory/ -w /massa-client/wallet-directory ghcr.io/f-lopes/massa-client:TEST.7.0 node_add_staking_private_keys <wallet_private_key> --ip ${NODE_IP}
```

You can verify your node is staking rolls by issuing this command:
```shell
docker run --rm -it -v /node-client-config-directory/:/massa-client/config/ -v /node-client-config-directory/:/massa-client/wallet-directory/ -w /massa-client/wallet-directory ghcr.io/f-lopes/massa-client:TEST.7.0 node_get_staking_addresses --ip ${NODE_IP}
```

Alternatively, you can put your private key into a `staking_keys.json` file and mount its directory into the container (see `staking_keys_path` in the `config.toml` file):
```shell
cat staking_keys.json
[
  "2excvw871qjhXzAtVu1C1f283fgasns35r9aP1wgU3M2v2ynnJ"
]
```

If you don't have a private key yet, see the next section.

#### Generating a wallet

:warning: Running this command will generate a private key and create a `wallet.dat` file in the mounted host directory.
Make sure to back up this file and make it accessible to the client container whenever needed (ie. `wallet_info`, `buy_rolls`, etc.).

```shell
docker run --rm -it -v /node-client-config-directory/:/massa-client/config/ -v $(pwd):/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.7.0 wallet_generate_private_key -w /massa-client/wallet-directory/wallet.dat
```

#### Inspecting the generated wallet

:memo: Make sure to share and reference your `wallet.dat` file (`-v /host/wallet/directory/:/massa-client/wallet-directory/`) each time you want to execute wallet-related commands.

```shell
docker run --rm -it -v /node-client-config-directory/:/massa-client/config/ -v /host/wallet/directory/:/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.7.0 wallet_info -w /massa-client/wallet-directory/wallet.dat
```

#### Buying rolls

To buy rolls, you need:
- a wallet (see the previous [section](#Generating-a-wallet))
- a node (RPC) running & accessible (private API port open)

```shell
docker run --rm -it -v /host/wallet/directory/:/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.7.0 buy_rolls <your_address>  <roll count> <fee> -w /massa-client/wallet-directory/wallet.dat --ip ${NODE_IP}
```

:grey_question: See [Massa documentation](https://github.com/massalabs/massa/wiki/staking#buying-rolls) for more details.

#### Testnet rewards

##### Registering your node

Registering your node requires interacting with the node private API.
To do so, please make sure that the node is listening to the `0.0.0.0` interface (see [settings](https://github.com/massalabs/massa/blob/main/massa-node/base_config/config.toml#L11)).

```shell
docker run --rm -it -v /config/directory/:/massa-client/config/ -v /host/wallet/directory/:/massa-client/wallet-directory/ ghcr.io/f-lopes/massa-client:TEST.7.0 wallet_info -w /massa-client/wallet-directory/wallet.dat node_testnet_rewards_program_ownership_proof --ip ${NODE_IP} <your_wallet_address> <your_discord_id>
```

:note:
You won't be able to SSH into these containers as they use a [distroless](https://github.com/GoogleContainerTools/distroless#why-should-i-use-distroless-images) base image.
:construction:
A specific tag will be available for debug needs.

## Feedback

Feel free to give any feedback in the [issues](https://github.com/f-lopes/massa-docker/issues) section.