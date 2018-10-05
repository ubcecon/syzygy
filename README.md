# syzygy
Support for the VSE Syzygy instance. 

## Usage

Command      | Description
-------------|------------
`./update-toml.sh`   | Pull latest TOML from `quantecon/lecture-source-jl`
`docker build -t syzygy:latest .` | Build image from Dockerfile and call it `syzygy:latest`. 
`docker run -it -p 8888:8888 -e JUPYTER_LAB_ENABLE=yes syzygy:latest` | Run Docker image.

## Troubleshooting 

> Permission denied for bash script

Try `chmod +x foo.sh`, which will add execute permissions. May need to `sudo chmod +x`. 

