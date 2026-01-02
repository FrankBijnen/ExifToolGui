This is all written from memory and I need to double-check the notes I have at another computer when actually implementing this.
So the information below might be incorrect in some parts but I believe I remembered everything.
Updates might come and as always, you who want to try this is out is responsible yourself for what you are doing.

**ONLINE MACHINE**

1) Install WSL 2 on Windows, I used Ubuntu 24.04 [POWERSHELL]:
Source: https://documentation.ubuntu.com/wsl/stable/howto/install-ubuntu-wsl2/#method-2-download-and-install-from-the-ubuntu-archive

2) Install Docker in WSL 2 [WSL]:
Source: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

3) Install "openstreetmap-tile-server" in Docker [WSL], see steps below:
Source: https://hub.docker.com/r/overv/openstreetmap-tile-server/

3.1) Create the Docker volume "osm-data" [WSL]:
Source: https://hub.docker.com/r/overv/openstreetmap-tile-server/
`docker volume create osm-data`

3.2) Download an ".osm.pbf" extract from geofabrik.de here for your specific region (I used "Europe" > "Sweden") [WSL]:
Source: https://hub.docker.com/r/overv/openstreetmap-tile-server/
Source: https://download.geofabrik.de/

3.3) Create the container and reference your downloaded extract [WSL]:
Source: https://hub.docker.com/r/overv/openstreetmap-tile-server/
Generic example:
```
docker run \
    -v /absolute/path/to/luxembourg.osm.pbf:/data/region.osm.pbf \
    -v osm-data:/data/database/ \
    overv/openstreetmap-tile-server \
    import
```
My example (where "/home/infinitebsod/sweden-251216.osm.pbf" should be the absolute path to your ".osm.pbf"):
```
docker run \
    -v /home/infinitebsod/sweden-251216.osm.pbf:/data/region.osm.pbf \
    -v osm-data:/data/database/ \
    overv/openstreetmap-tile-server \
    import
```

4) Export the "osm-data" volume [WSL]:
Source: https://www.augmentedmind.de/2023/08/20/backup-docker-volumes/
Generic example:
```
VOLUME="replace with the name of your volume"
docker run --rm -v "${VOLUME}:/data" -v "${PWD}:/backup-dir" ubuntu tar cvzf /backup-dir/backup.tar.gz /data
```
My example:
```
VOLUME="osm-data"
docker run --rm -v "${VOLUME}:/data" -v "${PWD}:/backup-dir" ubuntu tar cvzf /backup-dir/backup.tar.gz /data
```

5) Export Docker images
```
docker save  overv/openstreetmap-tile-server:latest --output overv-openstreetmap-tile-server.tar
docker save ubuntu:latest --output ubuntu-latest.tar
```

6) Prepare an external harddrive / USB-flashdrive and transfer the necessary files for the offline computer:
overv-openstreetmap-tile-server.tar = Docker image for the OpenStreetMap Tile Server you created earlier
ubuntu-latest.tar = Docker image for Ubuntu, required to restore the exported "osm-map" Docker-volume you created earlier
backup.tar = Backup of the Docker-volume "osm-map" you created earlier
wsl.2.6.3.0.x64.msi = WSL MSI-package from here: https://github.com/microsoft/wsl/releases
ubuntu-24.04.3-wsl-amd64.wsl = Ubuntu WSL-distribution from here: https://ubuntu.com/desktop/wsl

All deb-files below are found at: https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/:
containerd.io_<version>_<arch>.deb
docker-ce_<version>_<arch>.deb
docker-ce-cli_<version>_<arch>.deb
docker-buildx-plugin_<version>_<arch>.deb
docker-compose-plugin_<version>_<arch>.deb

**OFFLINE MACHINE**

1) Install WSL 2 on Windows, I used Ubuntu 24.04 [POWERSHELL]:

1.1) Activate Virtual Machine Platform and Windows Subsystem for Linux:
Source: https://learn.microsoft.com/en-us/windows/wsl/install#offline-install
`dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
`dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
<restart your computer>
1.2) Install latest WSL MSI-package (ex. wsl.2.6.3.0.x64.msi):
Source: https://github.com/microsoft/wsl/releases
1.3) Install the Ubuntu's WSL-distribution (ex. ubuntu-24.04.3-wsl-amd64.wsl):
Source: https://ubuntu.com/desktop/wsl
`wsl --install --from-file ubuntu-24.04.3-wsl-amd64.wsl`

2) Install Docker in WSL 2 [WSL]:
Source: https://docs.docker.com/engine/install/ubuntu/#install-from-a-package
Install all previous downloaded ".deb"-files for Docker by putting them all in a directory and run:
`sudo dpkg -i *.deb`

2.1) Test if Docker is working:
`sudo systemctl status docker`

2.2) Add your WSL-user to the Docker-group to invoke "docker" without "sudo":
`sudo usermod -aG docker $USER`

3.0) Import images and volumes to Docker [WSL]:
Source: https://www.augmentedmind.de/2023/08/20/backup-docker-volumes/

3.1) Import images:
```
docker load --input overv-openstreetmap-tile-server.tar
docker load --input ubuntu-latest.tar
```

3.2) Import exported volume:
My example:
```
docker create volume osm-data
VOLUME="osm-data"
docker run --rm -v "${VOLUME}:/data" -v "${PWD}:/backup-dir" ubuntu bash -c "rm -rf /data/{*,.*}; cd /data && tar xvzf /backup-dir/backup.tar.gz --strip 1"
```

4.0) Setup the overv/openstreetmap-tile-server Docker-container:
Source: https://hub.docker.com/r/overv/openstreetmap-tile-server/
Generic example / my example:
```
docker run \
    -p 8080:80 \
    -v osm-data:/data/database/ \
    -e ALLOW_CORS=enabled \
    -d overv/openstreetmap-tile-server \
    run
```

5.0) Setup ExifToolGui:

5.1) Download the pre-release version here:
https://1drv.ms/f/s!AhVJC-QzM33pknOS7KwBi09lgNql?e=n7ztFX
I installed it with all default settings

5.2) Download exiftool either from here:
https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows#toc-3
I used the "installer"-version above
or the tool without having to use an installer:
https://exiftool.org/
If using the installer use all default settings

5.3) Unsure if needed but start ExifToolGui so it generates the config in:
%appdata%\ExifToolGui\ExifToolGuiV6.ini

5.4) Modify the config in "%appdata%\ExifToolGui\ExifToolGuiV6.ini" and add:
```
[CustomBaseLayers]
Self Hosted 1=["http://localhost:8080/tile/${z}/${x}/${y}.png"]
```
Where "http://localhost:8080" is the hostname or IP to the machine running the OSM-Tile Server.
Remember you might need to port-forward to access the Docker-container inside WSL on the server that hosts OSM-Tile-Server:
`netsh interface portproxy add v4tov4 listenport=8080 connectaddress=<your-wsl-ip> connectport=8080`
You get your WSL-IP through:
`wsl hostname -i`
You might also need to open up Windows firewall:
`netsh advfirewall firewall add rule name="Allow 8080" dir=in action=allow protocol=TCP localport=8080`

5.5) In ExifToolGui:
Preferences > General > "-enable internet access for OSM Map" = Enabled
The tab "OSM Map" > Blue "+"-sign > "Self Hosted 1"

