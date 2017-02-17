# swarm creation

From instructions here: 
https://www.digitalocean.com/community/tutorials/how-to-create-a-cluster-of-docker-containers-with-docker-swarm-and-digitalocean-on-ubuntu-16-04


## Quickstart

    sh ./up.sh

when done:

    sh ./down.sh
    sh ./rm.sh

## Manual steps

### settings

    cp settings.example settings

Then update the settings and import them

    . settings

### create nodes

    for i in `seq 1 $num_nodes`; do docker-machine create --driver digitalocean \
      --digitalocean-image  ubuntu-16-04-x64 \
      --digitalocean-access-token $DOTOKEN node-$i; done

### firewall

From instructions here: 
https://www.digitalocean.com/community/tutorials/how-to-configure-the-linux-firewall-for-docker-swarm-on-ubuntu-16-04

    for i in `seq 1 $num_nodes`; do 
        if [ "$i" == "1" ]; then docker-machine ssh node-$i ufw allow 2377/tcp; fi
        docker-machine ssh node-$i 'ufw allow 22/tcp
                                    ufw allow 2376/tcp
                                    ufw allow 7946/tcp
                                    ufw allow 7946/tcp
                                    ufw allow 7946/udp
                                    ufw allow 4789/udp
                                    ufw reload
                                    ufw --force enable'
        docker-machine ssh node-$i systemctl restart docker
    done

### update os

    for i in `seq 1 $num_nodes`; do
        docker-machine ssh node-$i 'apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && reboot'
    done

### create swarm 

    for i in `seq 1 $num_nodes`; do
        if [ "$i" == "1" ]; then
            manager_ip=$(docker-machine ip node-$i)
            eval $(docker-machine env node-$i) && \
              docker swarm init --advertise-addr "$manager_ip"
            worker_token=$(docker swarm join-token worker -q)
        else
            eval $(docker-machine env node-$i) && \
              docker swarm join --token "$worker_token" "$manager_ip:2377"
        fi
    done

### stop machines (digitalocean doesn't bill unless droplets are running)

    for i in `seq 1 $num_nodes`; do
        docker-machine stop node-$i
    done
 
### delete machines (this deletes the droplets from digitalocean

    for i in `seq 1 $num_nodes`; do
        docker-machine rm --force node-$i
    done

