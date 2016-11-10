### Testing the response time of .dev and .local on OSX

Setup and test

```sh
./setup.sh && ./test.sh
```

Checkout the [results](results) – the important findings are:

- macOS Sierra has a 5 second look-up for **.dev** and **.local** entries in `/etc/hosts`
- El Captain has a 5 second look-up for **.local**
- Seemingly all other TLDs (including nonsense ones) don't have this problem
- in both cases adding a word between the ip and the hostname like `127.0.0.1 arbitrary test.local` cuts that 5 seconds back down to the expected tens of milliseconds

In other words `127.0.0.1 test.local` is slow:

```
$ cat /etc/hosts

127.0.0.1   localhost
255.255.255.255   broadcasthost
::1             localhost

127.0.0.1 test.local

$ curl -w '@curl-template.txt' -s http://test.local -o /dev/null

     time_namelookup:  5.003
        time_connect:  5.004
    time_pretransfer:  5.004
  time_starttransfer:  5.004
          ------------------
          time_total:  5.005
```

but `127.0.0.1 arbitrary test.local` is fast:

```
$ cat /etc/hosts

127.0.0.1   localhost
255.255.255.255   broadcasthost
::1             localhost

127.0.0.1 arbitrary test.local

$ curl -w '@curl-template.txt' -s http://test.local -o /dev/null

     time_namelookup:  0.006
        time_connect:  0.000
    time_pretransfer:  0.000
  time_starttransfer:  0.000
          ------------------
          time_total:  0.006
```
