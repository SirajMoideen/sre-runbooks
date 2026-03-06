## Change Docker Network Range of running container to avoid the conflict with private IP range

1. ### Create a New Docker Network:    (Replace \<new\_network\_name\> and \<new\_subnet\> with your desired network name and subnet.)

```
docker network create --subnet=<new_subnet> <new_network_name>

eg:
docker network create --subnet=172.17.1.0/24 docker-network
```

2. Check docker is using which network  
   1. To check which network a specific Docker container is using, you can use the docker container inspect command  
      Replace \<container\_name\_or\_id\> with the actual name or ID of your container.

```
docker container inspect -f '{{.NetworkSettings.Networks}}' <container_name_or_id>
```

      Here ‘docker\_default’ is the network

      

   2. for container id

```
docker ps
```

   3. Check with the docket network and match it

```
sudo docker network ls
```

3. ### Disconnect Containers from the Old Network:

```
docker network disconnect <current_network> <container_name_or_id>
```

4. ### Connect Containers to the New Network:

```
docker network connect <new_network_name> <container_name_or_id>
```

5. ### Verify the Changes:

```
docker network inspect <new_network_name>
```

6. ### Remove the Old Network:

```
docker network rm <old network>
```

7. Done

8. You can use the below command as well, to check which network is using (optional)

```
docker container inspect -f '{{.NetworkSettings.Networks}}' <container_name_or_id>
```

## Change the default range of docker

Article URL: https://serverfault.com/questions/916941/configuring-docker-to-not-use-the-172-17-0-0-range

1. Edit /etc/docker/daemon.json If it doesn't exist, you can create it.  
   1. edit daemon.json

```
vi /etc/docker/daemon.json
```

   2. Copy paste the below to the daemon.json file

```
{
  "default-address-pools": [
    {"base":"172.17.0.0/16","size":24}
  ]
}
```

OR

```
{
  "default-address-pools": [
    {"base":"172.30.0.0/16","size":24}
  ]
}
```

3. Save\!

2. Restart the docker service

```
sudo systemctl restart docker
```

3. To test create a dummy network

```
docker network create test
```

   

4. To check the range

```
docker network inspect test | grep Subnet
```

5. To remove the network

```
docker network rm test
```

6. Done\!

## To change the default network range of docker (if the default network unused)

1. Note the default docker name

```
sudo docker network ls
```

2. To check if any container is using the docker\_default

```
docker network inspect <new_network_name>eg:docker network inspect docker_default
```

3. Once verified delete the current network

```
docker network rm <current docker name>eg:
docker network rm docker_default
```

4. Change the default range of docker

   1. Edit /etc/docker/daemon.json If it doesn't exist, you can create it.

```
vi /etc/docker/daemon.json
```

   2. Copy paste the below to the daemon.json file

```
{
  "default-address-pools": [
    {"base":"172.17.0.0/16","size":24}
  ]
}
```

OR

```
{
  "default-address-pools": [
    {"base":"172.30.0.0/16","size":24}
  ]
}
```

3. Save\!

   

5. Restart the docker service

```
sudo systemctl restart docker
```

6. Create a new network with the same name as previous name

```
docker network create <deleted docker network name>eg: docker network create docker_default

##Verifydocker network inspect docker_default
```

7. Done\!

## Delete route if it’s tagged

1. check the route

```
route
```

2. If it’s tagged the ip range, then delete the route entry

```
sudo ip route del 172.19.0.0/16 dev br-22d5852a003f
```

3. Done