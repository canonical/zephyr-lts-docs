# Contribute to the Zephyr documentation

Follow the [Ubuntu Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct).

## Get the source

Clone the documentation repository from GitHub:

```shell
git clone https://github.com/canonical/zephyr-lts-docs.git
cd zephyr-lts-docs
```

Create a branch for your change:

```shell
git switch -c <branch-name>
```

## Write the change

The documentation uses the [Diátaxis framework](https://diataxis.fr/).

- Put lessons in `docs/tutorials/`.
- Put task procedures in `docs/how-to/`.
- Put technical facts in `docs/reference/`.
- Put conceptual information in `docs/explanation/`.

Use short active sentences. Give one instruction in each sentence.
Use the same term for the same item throughout a page.

## Check the change

Build the documentation:

```shell
make -C docs html
```

Run the documentation checks:

```shell
make -C docs spelling
make -C docs linkcheck
make -C docs woke
make -C docs lint-md
```

## Propose the change

Push the branch to your GitHub fork.
Open a pull request against `canonical/zephyr-lts-docs`.

State the problem, the change, and the checks that you ran.
