To clear Docker images and containers that are not in use, you can follow these steps:

To see the docker disk usage

```
docker system df
```

## docker system prune:

This will remove:  
  \- all stopped containers  
  \- all networks not used by at least one container  
  \- all dangling images  
  \- unused build cache

```
docker system prune

#Force clean the images
docker system prune -a -f
```

## Remove Containers:

1. List all containers:

```
docker ps -a
```

   

2. Remove stopped containers: (This command will remove all stopped containers.)

```
docker container prune
```

3.  Remove specific container(s):  
   (Replace \<container\_id1\>, \<container\_id2\>, etc., with the actual IDs of the containers you want to remove)

```
docker rm <container_id1> <container_id2>
```

## Remove Images:

1. List all images:

```
docker images -a
```

2. Remove unused images:

```
docker image prune
```

3. Remove specific image(s):

```
docker rmi <image_id1> <image_id2>
```

   

## Remove Volumes (Optional):

1. If you also want to remove unused volumes, you can use the following command:

```
docker volume prune
```

## Combine Commands (Recommended):

1. To perform all the cleanup in one go, you can use the following commands:

```
docker container prune -f
docker image prune -f
docker volume prune -f
```

The \-f flag is used to force the removal without interactive confirmation.

Always be careful when removing containers, images, or volumes, as this action is irreversible. Make sure you don't remove anything important.

OR

## Combine Commands \- 2 (optional) :

You can combine these commands to perform a comprehensive cleanup:

```
docker ps -a -q --filter "status=exited" | xargs docker rm
docker images -q --filter "dangling=true" | xargs docker rmi
docker volume ls -qf "dangling=true" | xargs docker volume rm
```

This set of commands removes stopped containers, unused images, and unused volumes in one go. Always be cautious and review the list of items to be removed before executing these commands to avoid unintentional data loss.
