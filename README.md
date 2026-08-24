# Zephyr 24.04 documentation

This repository contains the documentation for Zephyr 24.04.

Canonical maintains the Zephyr source and its modules in the [Zephyr RTOS
Launchpad project](https://code.launchpad.net/~arctic-tern/zephyr-rtos).

## Build the documentation

Install the Python virtual environment package on Ubuntu:

```shell
sudo apt install python3-venv
```

Build the HTML documentation:

```shell
make -C docs html
```

Run the local documentation server:

```shell
make -C docs run
```

Open <http://127.0.0.1:8000>.

## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) before you propose a change.

Report security problems as described in [SECURITY.md](SECURITY.md).
