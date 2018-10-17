# Only run if the .julia doesn't exist
mkdir -p /home/jupyter/.julia # Create the directory structure if it doesn't exist. 
cp -r /home/jovyan/.julia/environments /home/jupyter/.julia/ # Copy in our environments
