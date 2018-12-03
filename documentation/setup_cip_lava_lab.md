# How to setup your own CIP LAVA lab #

## Prerequisites ##
As well as the packages docker, docker-compose and pyyaml mentioned in the top
level README, you will need the following:

1) The following ports are forwarded to docker and therefore need to be kept free
on the host machine:
- 69/UDP: proxyfied to the slave for TFTP
- 80: proxyfied to the slave for TODO (transfer overlay)
- 5500: proxyfied to the slave for Notification
- 55950-56000: proxyfied to the slave for NBD
2) You will need a remote power switch to remotely power the DUTs on and off.
3) You need to have an account with lava.ciplatform.org. Please contact the
cip-dev mailing list if you would like an account, and include that you would
like to create your own lab in the email so that the relevant user permissions
can be set.

## Steps to create your own LAVA lab ##

1) Clone CIP lava-docker image:
```
git clone https://gitlab.com/cip-project/cip-testing/lava-docker.git
cd lava-docker
git checkout -b tmp cip-lava-docker
```

2) On the LAVA master web GUI, create a new API token:
https://lava.ciplatform.org/api/tokens/

3) Connect all the DUTs' serial to usb and ethernet connections to the host.

4) Create a slave zmq certificate
```
zmqauth/zmq_auth_gen/create_certificate.py --directory . nameofyourslave
```
This will create a:
- public key ending with ".key"
- private key ending with ".key_secret"

Please place these in a sensible directory eg. ../certificates.d
You will need to exchange the public slave key with the public master key. Please
contact the cip-dev mailing list to obtain the public master key.  
Place the public master key in your certificates directory and create a dummy
master public certificate in the certificates directory. It should be named
*lava.ciplatform.org.key_secret*.

5) Edit the boards.yaml file:
- Copy the API token you created in step 2 in the place of <generated_lab_token>.
- Add the filepaths of the zmq keys of the master and and the slave lab in their
respective locations.
- Add details of each board connected to the lab. See the top level README for
instructions. You will need the following:
- any custom options you require in the kernel args
- uart idvendor, idproduct, devpath
- power on, off and reset commads for the power switch

To get the uart idvendor and idproduct, unplug and re-plugin the USB cable of the
device in question and then find the details in the latest output of:
```
sudo dmesg | grep idvendor
```

To get the uart devpath, run the command:
```
udevadm info -a -n /dev/ttyUSB1 |grep devpath | head -n1
```

NOTE: Make sure you have at least one "board" included. (It is easiest to keep qemu).

6) Run the automated setup script:
```
./lavalab-gen.sh
cd output/<name_of_lab>
./deploy.sh
```

7) Check the web GUI to see if the lab has successfully connected to the LAVA
master: https://lava.ciplatform.org/scheduler/allworkers. If it isn't, run the
following command for debugging:
```
docker-exec -it <name_of_docker_container> cat /var/log/lava-dispatcher/lava-slave.log
```
To identify the container name run the following to list the running containers:
```
docker ps
```

## Adding new device-type templates ##

Not all device types are supported by default. Templates for new devices will
need to be added to the LAVA master. Please submit new templates to the cip-dev
mailing list.

Before you submit any new device-type templates, please verify that they work. You can varify that they work in LAVA by carrying out the following instructions:
1) Install lavacli on Debian Stretch or Ubuntu 18.04 and later (if you don't have a compatible OS, please see https://lava.ciplatform.org/api/help/ for an alternative way to use the API)
2) Create your lavacli config file 
```
touch ~/.config/lavacli.yaml
```
3) Configure this file to look like the following (note: use the first token created in https://lava.ciplatform.org/api/tokens/)
```
default:
  uri: https://lava.ciplatform.org/RPC2
  username: <username>
  token: <API_token>
```
4) Add your device template to the master
```
lavacli device-types template set <device-type-name> <device-type-name>.yaml
```
NOTE: make sure your device-type templates always follow the following naming scheme: ```<device-type-name>.yaml```
