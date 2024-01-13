---
layout: post
title: development-environment-databases-ondemand
date: 2024-01-10 20:40 +0300
categories: [development]
tags: [databases, environment-setup, docker]
---

# Databases on demand for your dev environment

## why u wanna do this 

instead of running multiple server (mySql, SQLServer, Postgres, . . .) and have to either stop/start their service, you can just set them up using docker and use them when u want, or have multiple instances of the same provider running on different ports easily.

or when setting up a new windows machine, instead of installing all one by one, you have them on demand, for linux there's ansible. . . 

> in some cases tho you'd need a certain `dll` for a library to work, like in rust's diesel case. which u can download and point diesel to the folder u've downloaded it in. 

## Setup using docker compose

- i've been using this setup for a while now, here's my [repo](https://github.com/CanaanGM/databases-infrastructure) which u can use as a refernce or a starting point. _th readme needs cleaning up tho_

i like keeping each in their own folder so it's clean and tidy when it comes to their folder data.

> basically what you do is have a **docker-compose.yml** for each instance and just start and stop with docker commands.

in docker you can set environment variable either in a text file or .env file, i never used the text file option so here how to do it in .env:

1. have you `.env` file :

```text
DATABASE_USER=example
DATABASE_PASSWORD=example1234
```

2. in docker-compose you can load them in with `${}` :

```yaml
DATABASE_USER=${DATABASE_USER}
```

--- 


### MySql example

```yaml
version: "3.8"

services: 
  mySQL:
    image: mysql  <-- i recommend using a set version so ur data don't get messed with on a new version update
    environment:
      MYSQL_ROOT_PASSWORD: root   <-- you can use ${.env} 
    restart: always               <-- so it starts as soon as docker desktop starts 
    container_name: mySqlDockerMain <-- give it a name
    ports:
      - "3306:3306"  <-- what ports
    volumes: 
      - "./mySql-db-data:/var/lib/mysql"
        ________________ the data folder which will get created locally
                           |
volumes:                   |
  db-data:           <------

```
"without the annotations"
```yaml
version: "3.8"

services: 
  mySQL:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
    restart: always
    container_name: mySqlDockerMain
    ports:
      - "3306:3306"
    volumes: 
      - "./mySql-db-data:/var/lib/mysql"

volumes: 
  db-data:
```

## More "involved" examples

### Kafka cluster and zookeeper 
> you can run the entire thing using `docker compose up` cool!
- the [docker raw file](https://raw.githubusercontent.com/CanaanGM/databases-infrastructure/main/kafka/docker-compose.yml)
  - _obviously you can play around with it more, but i'm still learning it_ (●'◡'●) 
- `docker compose up` (with or without _-d_)
![pullit](/assets/images/db-env-setup/DBEnvPullingKafka.png)
- test it thru [offset explorer](https://www.kafkatool.com/download.html)
  - in the advanced tab, in Bootstrap servers: broker:29090, localhost:9092 
  - ![setup-1](/assets/images/db-env-setup/DBEnv-OffsetExplorer.png)
  - ![setup-2](/assets/images/db-env-setup/DBEnv-OffsetExplorer-setup.png)
  - ![setup-3](/assets/images/db-env-setup/DBEnv-OffsetExplorer-setup1.png)

### Aerospike

in this case you've only got to give it the **aero_config** folder as [like this](https://github.com/CanaanGM/databases-infrastructure/tree/main/aerospike)

### Airflow

same thing as AeroSpike but the folder is named **dags** and it would house ur handmade _.py_ scripts

after it is done initializing, you can navigate tp `localhost:8080` user and password : `airflow`

you should see a lot of dummy tags which you can play with, but ***remember*** : the tag names are **not the names of the python scripts** **but the name you gave the dag inside of it**:

![dag](/assets/images/db-env-setup/DBEnv-Airflow-dag.png){: width="972" height="600" .w-50 .right}

```py
def crap():
    print("I am POWER!")

default_args = {
    'owner': 'Test',
    'depends_on_past': False
}
dag = DAG(
    'crap', <=- this is the name of the dag!
    default_args=default_args,
    start_date=days_ago(0)
)
task1 = PythonOperator(
    task_id="CRAP",
    python_callable=crap,
    dag=dag
)
```

## closing

normally you'll always find documentation for a provider u wanna use in docker, just either search dockerhub or uncle google, if you couldn't find anything tho, you can always try to install and run it normally and see what environment vars or other things it may need.

or if you found a docker container all the better, you can spin it up and ssh inside it, or use docker desktop to do so!
