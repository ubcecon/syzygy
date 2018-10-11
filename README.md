# syzygy
Support for the VSE Syzygy instance. 

## Usage

Command      | Description
-------------|------------
`docker build -t syzygy:latest .` | Build image from Dockerfile and call it `syzygy:latest`. 
`docker run -it -p 8888:8888 -e JUPYTER_LAB_ENABLE=yes syzygy:latest` | Run Docker image.
`docker run -i -t syzygy:latest /bin/bash` | Run as container. 
`./pull-toml.sh`   | Download latest TOML from `quantecon/lecture-source-jl`.
`./buildrun.sh` | Do (1) and (2). 

## Troubleshooting 

> Permission denied for bash script

Try `chmod +x foo.sh`, which will add execute permissions. May need to `sudo chmod +x`. 

> Bind for 0.0.0.0:8888 failed: port is already allocated.

Try restarting docker. 