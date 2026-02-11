# Terraform OCI Provider

------

**All of the following codes must be executed in the `oci` directory.**

On the first run, execute login command

```shell
terraform login
```



## Setup Dependency

```shell
sudo apt update && sudo apt install -y age direnv

SOPS_VER="3.11.0"
curl -LO https://github.com/getsops/sops/releases/download/v$SOPS_VER/sops_$SOPS_VER_amd64.deb && \
sudo dpkg -i sops_$SOPS_VER_amd64.deb && \
rm sops_$SOPS_VER_amd64.deb

grep -qq 'direnv hook bash' ~/.bashrc || echo -e '\neval "$(direnv hook bash)"' >> ~/.bashrc

eval "$(direnv hook bash)"
[ -f ".envrc" ] && direnv allow .

sops --version
```



## Generate Age Key


```shell
age-keygen -o oci_key.txt
chmod 400 oci_key.txt
mkdir -p ~/.age/
mv oci_key.txt ~/.age/
chmod 700 ~/.age
```



paste public key at `.sops.yaml`

```yaml
creation_rules:
  - path_regex: keys/.*\.json$
    age: "[paste age public key here]"
```



## Secret Create

```shell
sops -e keys/secret.json > keys/secret.enc.json
```

*Note: This will overwrite the existing `keys/secret.enc.json` file.*



## Secret Modify

```shell
sops keys/secret.enc.json
```



## Secret Decrypt

```shell
sops -d keys/secret.enc.json > keys/secret.json
```

*Note: This will overwrite the existing `keys/secret.json` file.*



## Injecting Wireguard Configuration


```shell
cat script/wg0.conf | base64 -w 0
```



Paste the output into the `wg0_conf` key

```json
{
    ...
    "wg0_conf": "[paste base64 string here]",
    ...
}
```

Code decryption is handled by init_script.
