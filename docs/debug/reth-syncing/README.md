# Debug reth on perf-devnet-2

Running reth with the usual `--bootnodes` setup (It's automatically populated by the ethereum package):

```sh
kurtosis run github.com/ethpandaops/ethereum-package@main --args-file reth.yaml --enclave perf-devnet-2-reth --image-download always
```


Running reth with `--bootnodes`, `--trusted-peers`, `--trusted-only`:

```sh
kurtosis run github.com/ethpandaops/ethereum-package@main --args-file reth-trusted-peers.yaml --enclave perf-devnet-2-reth-trusted --image-download always
```

If you want to run it without docker and need any of the config files you can use `kurtosis enclave dump <enclave_name>`.
