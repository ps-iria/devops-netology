# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка 

**\l**
- подключения к БД

**\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}**
- вывода списка таблиц

**\dt**
- вывода описания содержимого таблиц

**\dt+**
- выхода из psql

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sql
select * from test_database.pg_catalog.pg_stats where tablename = 'orders' and 
	avg_width = (select MAX(avg_width) FROM test_database.pg_catalog.pg_stats where tablename = 'orders')
```

schemaname|tablename|attname|inherited|null_frac|avg_width|n_distinct|most_common_vals|most_common_freqs|histogram_bounds                                                                                                                                 |correlation|most_common_elems|most_common_elem_freqs|elem_count_histogram|
----------|---------|-------|---------|---------|---------|----------|----------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-----------|-----------------|----------------------|--------------------|
public    |orders   |title  |false    |      0.0|       16|      -1.0|                |NULL             |{"Adventure psql time",Dbiezdmin,"Log gossips","Me and my bash-pet","My little database","Server gravity falls","WAL never lies","War and peace"}| -0.3809524|                 |NULL                  |NULL                |

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

```sql
BEGIN; 
	CREATE TABLE orders_1 (
	check (price > 499)
	) inherits (orders);

	CREATE TABLE orders_2 (
	check (price <= 499)
	) inherits (orders);

	INSERT INTO orders_1 (id,title,price)
	SELECT id,title,price
	from orders
	where price > 499;
	
	INSERT INTO orders_2 (id,title,price)
	SELECT id,title,price
	from orders
	where price <= 499;
COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

**`Можно, исполььзуя PARTITION BY и PARTITION OF`**

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```title character varying(80) NOT NULL UNIQUE,```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
