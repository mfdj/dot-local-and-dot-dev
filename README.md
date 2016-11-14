### Project Impeteus

For local development it's typical to use `/etc/hosts` to use custom hostnames for projects. Typically it takes a **less than 10 milliseconds** for the OS to resolve the etc-host entries.

However on macOS/OSX it can take **mulitple seconds** to resolve certain hostnames specifically ones containing either `.local` or `.dev` in the TLD. This repo exists to help diagnose this issue, raise awarness of it, and suggests some simple workarounds.

### Running the tests

**Requirements**

Homebrew

**Running the tests**

Assuming you are using Homebrew you can clone and test pretty easily. If you use Homebrew'd Apache 2.4 for active development you should double-check the source first, but it's simply:

```sh
./setup.sh # run once
./test.sh
```

### Findings

You can check the detailed [results](results) but the important findings are:

- typically macOS resolves `/etc/hosts` entries in a less than 10ms
- macOS Sierra has a 5s look-up for **.dev** and **.local** entries in `/etc/hosts`
- El Captain has a 5s look-up for **.local**
- in both cases adding a word between the ip and the hostname like `127.0.0.1 arbitrary test.local` cuts that 5s back down to milliseconds

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

### Why?

I'm curious why this is happening!

[man hosts](http://man7.org/linux/man-pages/man5/hosts.5.html) says:

> For each host a single line should be present with the following information: 
>   _IP\_address canonical\_hostname [aliases...]_

Seemingly .dev and .local are less responsive as canonical-hostnames than as aliases?
