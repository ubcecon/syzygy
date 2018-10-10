docker build -t syzygy:latest .
docker run -it -p 8888:8888 -e JUPYTER_LAB_ENABLE=yes syzygy:latest