# Building

## Update Git Hashes
Update `FREETZ_CURRENT_COMMIT_HASH` and `FFRITZ_CURRENT_COMMIT_HASH` with the current commit hash from:

- https://bitbucket.org/fesc2000/ffritz/commits/branch/6591
- https://github.com/Freetz-NG/freetz-ng/commits/master

## ffritz

### Building the image
`docker build --pull -t pfichtner/freetz:latest --platform linux/amd64 .`

### Building the firmware
```sh
docker run -it --platform linux/amd64 -v $(pwd)/firmware/:/workspace/ffritz/images/ pfichtner/freetz:latest 

# inside the container, run:
make
#`make rebuild` to not use the pre-built library binaries - takes forever

# find the image in your local filesystem at ./firmware/fbxxx.tar
# then type `exit`
```

### Install the firmware

1. Download diagnostic data from http://192.168.178.1/support.lua
1. Gain console access via serial (old bios) or EVA (new bios) (see https://bitbucket.org/fesc2000/ffritz/src/6591/README-6591.md)
1. Backup partitions to Mediaserver
1. Download partitions
1. Install firmware https://bitbucket.org/fesc2000/ffritz/src/6591/README.md
1. Setup SSH https://bitbucket.org/fesc2000/ffritz/src/6591/README.md#first-use

### Updating the firmware

1. Update commit hashes in the `Dockerfile``
1. Build a new firmware image
1. Copy the image to the box (via ftp or NAS) 
1. Login via SSH or telnet (telnet: fritzbox user and web password) within the first 10 minutes after restart
1. see https://bitbucket.org/fesc2000/ffritz/src/6591/README.md#markdown-header-installing-the-image-with-sshtelnetconsole-access

## freetz

### Building the image
`docker build --pull -t pfichtner/freetz:latest --platform linux/amd64 .`

### Building the firmware
```sh
docker run -it --platform linux/amd64 -v $(pwd)/firmware/:/workspace/ffritz/images/ pfichtner/freetz:latest 

# inside the container, run:
make
#`make rebuild` to not use the pre-built library binaries - takes forever

# find the image in your local filesystem at ./firmware/fbxxx.tar
# then type `exit`
```