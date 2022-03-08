# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

```dockerfile
FROM centos:7

ENV ES_HOME=/elasticsearch-8.0.1
ENV ES_JAVA_HOME=/elasticsearch-8.0.1/jdk
ENV ES_JAVA_OPTS="-Xms128m -Xmx128m"
ENV PATH=$PATH:/elasticsearch-8.0.1/bin

RUN yum update -y --setopt=tsflags=nodocs && \
yum install -y perl-Digest-SHA && \
yum install -y wget && \
rm -rf /var/cache/yum

RUN groupadd elasticsearch && \
useradd elasticsearch -g elasticsearch -p elasticsearch

RUN mkdir -p /var/lib/elasticsearch/logs && \
mkdir -p /var/lib/elasticsearch/snapshots && \
mkdir -p /var/lib/elasticsearch/data


RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz && \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 && \
shasum -a 512 -c elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-8.0.1-linux-x86_64.tar.gz && \
rm elasticsearch-8.0.1-linux-x86_64.tar.gz && \
chown -R elasticsearch:elasticsearch ${ES_HOME} && chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

ADD elasticsearch.yml ${ES_HOME}/config/elasticsearch.yml

EXPOSE 9200

WORKDIR ${ES_HOME}

USER elasticsearch

CMD ["elasticsearch"]
```

- ссылку на образ в репозитории dockerhub

[Репозиторий](https://hub.docker.com/repository/docker/psiria/netology_test)

- ответ `elasticsearch` на запрос пути `/` в json виде

```json
sh-4.2$ curl -X GET localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "netology_test_cluster",
  "cluster_uuid" : "8q2cj0DlRYOZeTpl4c3pNg",
  "version" : {
    "number" : "8.0.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "801d9ccc7c2ee0f2cb121bbe22ab5af77a902372",
    "build_date" : "2022-02-24T13:55:40.601285296Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```shell script
$ curl -X GET "localhost:9200/_cat/indices?v"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 LLBr6re4SYSVXJMVKz4ukQ   1   0          0            0       225b           225b
yellow open   ind-3 vku_Y_V-REGL9Y1ZOWkIRA   4   2          0            0       225b           225b
yellow open   ind-2 15trGhcbS9e580g5QXkuGg   2   1          0            0       450b           450b

```

Получите состояние кластера `elasticsearch`, используя API.

```shell script
$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology_test_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

**В данном кластере только одна нода и индексы не могут реплицировать, если добавить больше нод то индексы изменят статус на GREEN, и после этого кластер также сменит свой статус**

Удалите все индексы.

```shell script
$ curl -X DELETE "localhost:9200/ind-1?pretty"
{
  "acknowledged" : true
}

$ curl -X DELETE "localhost:9200/ind-2?pretty"
{
  "acknowledged" : true
}

$ curl -X DELETE "localhost:9200/ind-3?pretty"
{
  "acknowledged" : true
}

$ curl -X GET "localhost:9200/_cat/indices?v"
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size

$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology_test_cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```shell script
$ curl -X PUT "localhost:9200/_snapshot/netology_backup?verify=false&pretty" -H 'Content-Type: application/json' -
d'
> {
>   "type": "fs",
>   "settings": {
>     "location": "/var/lib/elasticsearch/snapshots"
>
>   }
> }
> '
{
  "acknowledged" : true
}

```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```shell script
$ curl -X GET "localhost:9200/_cat/indices?v"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  2h5ZWv3oTWu4QCMm3FAchg   1   0          0            0       225b           225b

```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```shell script
sh-4.2$ ls -l
total 36
-rw-r--r-- 1 elasticsearch elasticsearch   844 Mar  8 11:16 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Mar  8 11:16 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Mar  8 11:16 indices
-rw-r--r-- 1 elasticsearch elasticsearch 17468 Mar  8 11:16 meta-9xq9_Fj9Tkm36o_JZNklcQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch   353 Mar  8 11:16 snap-9xq9_Fj9Tkm36o_JZNklcQ.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```shell script
$ curl -X GET "localhost:9200/_cat/indices?v"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 gZ4FKJs3SryrjweY-p9oEw   1   0          0            0       225b           225b

```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```shell script
$ curl -X GET "http://localhost:9200/_snapshot/netology_backup/*?verbose=false&pretty"
{
  "snapshots" : [
    {
      "snapshot" : "my_snapshot",
      "uuid" : "9xq9_Fj9Tkm36o_JZNklcQ",
      "repository" : "netology_backup",
      "indices" : [
        ".geoip_databases",
        "test"
      ],
      "data_streams" : [ ],
      "state" : "SUCCESS"
    }
  ],
  "total" : 1,
  "remaining" : 0
}

$ curl -X POST http://localhost:9200/_snapshot/netology_backup/my_snapshot/_restore
{"accepted":true}
$ curl -X GET "localhost:9200/_cat/indices?v"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 gZ4FKJs3SryrjweY-p9oEw   1   0          0            0       225b           225b
green  open   test   i9dqGQWkQ7eb6FuacTyQ4Q   1   0          0            0       225b           225b

```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
