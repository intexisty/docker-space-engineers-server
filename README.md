# Space Engineers on Linux
Docker container for running a Space Engineers server
There is no public prebuilt container image because of copyright restrictions
These instructions will guide you to configure the environment and build your own container

## Setup
- Create the required directory structure.

```bash
mkdir -p space-engineers/{docker,data,steam}
mkdir -p space-engineers/data/Space\ Engineers/{Mods,Saves}
```

- Clone this repository into the home directory of the new user account.

```bash
git clone https://github.com/ChipWolf/se-server.git space-engineers/docker
```

- Obtain a copy of the most current `DedicatedServer.zip` and place it in `~/games/space-engineers/data`. You may use this method below. 


```bash
docker run --rm -it -v $(pwd)/space-engineers/steam:/data wilkesystems/steamcmd

# the following 4 commands are for the steamcmd terminal
login anonymous
force_install_dir /data
app_update 298740 validate
quit
```

- At this stage we need to patch a few .dlls to fix an issue with mods not downloading, thanks to [Thomas\_Jefferson](https://forum.keenswh.com/members/thomas_jefferson.3913080/) from the Keen Software House forum for this one.

![](https://i.cwlf.uk/Jxav4.png)

```
cd space-engineers/steam
zip -r ../data/DedicatedServer.zip
cd ../..
sudo chown -R 256:256 space-engineers
```

- Upload your `SpaceEngineers-Dedicated.cfg` and place it in `~/games/space-engineers/data/Space Engineers`. Use the one in this repository and edit it to your liking if you do not already have one.

- **Build the image!** *(This will take a while)*

```bash
space-engineers/docker/build.sh
```

#### Starting the server

```bash
docker run -it -p 27016:27016/udp -v $(pwd)/games/space-engineers/data:/host --rm --name space-engineers saiban/space-engineers
```

![](https://i.cwlf.uk/PPXyG.png)

---

## Additional notes
Running Space Engineers this way requires a helper program called `sigmap` which was developed for this use specifically. It is cloned and built by the Dockerfile and should not add any additional overhead. Because Space Engineers ignores `SIGTERM` which is sent by Docker to shut down the service, `sigmap` catches that signal and forwards `SIGINT` to Space Engineers.

See [here](https://github.com/marjacob/sigmap "sigmap") for more information.

## Credits
The original `Dockerfile` was written by [webanck](https://github.com/webanck "webanck") and can be found [here](https://github.com/webanck/docker-wine-steam "Steam with Docker").

This repo has been adapted from [marjacob](https://github.com/marjacob "marjacob")'s efforts.
