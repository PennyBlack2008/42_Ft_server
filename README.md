# Build image
docker build -t ft_server .

# Run image
docker run --name jikang -it -p 80:80 -p 443:443 ft_server