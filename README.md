Testing the response time of .dev and .local on OSX

Setup and test

```sh
./setup.sh
./test.sh
```

Checkout the [results](results) – the important findings are:

- macOS Sierra has a 5 second look-up for **.dev** and **.local** entries in `/etc/hosts`
- El Captain has a 5 second look-up for **.local**
- Seemingly all other TLDs (including nonsense ones) don't have this problem
- in both cases adding a word between the ip and the hostname like `127.0.0.1 arbitrary test.dev` cuts that 5 seconds back down to the expected tens of milliseconds
