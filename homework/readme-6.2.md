# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```sh
F:\netology\06-db-02-sql>docker volume create --name db
db

F:\netology\06-db-02-sql>docker volume create --name backup
backup

F:\netology\06-db-02-sql>docker run --name postgress -d -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password -p 5433:5432 -v db:/var/lib/postgresql/data -v b
ackup:/usr/share/backup postgres:12-alpine
81c829fdefd79778805bab2367912c256dc3564fd9dbf017849fc7497db329b7
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,

```sql
SELECT * FROM pg_catalog.pg_tables pt WHERE pt.schemaname IN ('public')
```

|schemaname|tablename|tableowner|tablespace|hasindexes|hasrules|hastriggers|rowsecurity|
|----------|:-------:|---------:|---------:|---------:|-------:|----------:|----------:|
|public    |orders   |postgres  |          |true      |false   |true       |false      |
|public    |clients  |postgres  |          |true      |false   |true       |false      |

- описание таблиц (describe)

```sql
SELECT 
   table_name, 
   column_name, 
   data_type 
FROM 
   information_schema."columns" c 
WHERE 
   c.table_name IN ('clients', 'orders')
```
|table_name|column_name|data_type        |
|----------|-----------|-----------------|
|orders    |id         |integer          |
|orders    |name       |character        |
|orders    |cost       |integer          |
|clients   |id         |integer          |
|clients   |surname    |character varying|
|clients   |country    |character varying|
|clients   |order_id   |integer          |

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```sql
SELECT 
   tp.grantee,
   tp.table_name,
   tp.privilege_type
FROM 
   information_schema.table_privileges tp  
WHERE 
   tp.table_name IN ('clients', 'orders') and 
   tp.grantee in ('test-admin-user', 'test-simple-user')
```

- список пользователей с правами над таблицами test_db

grantee         |table_name|privilege_type|
----------------|----------|--------------|
test-admin-user |orders    |INSERT        |
test-admin-user |orders    |SELECT        |
test-admin-user |orders    |UPDATE        |
test-admin-user |orders    |DELETE        |
test-admin-user |orders    |TRUNCATE      |
test-admin-user |orders    |REFERENCES    |
test-admin-user |orders    |TRIGGER       |
test-simple-user|orders    |INSERT        |
test-simple-user|orders    |SELECT        |
test-simple-user|orders    |UPDATE        |
test-simple-user|orders    |DELETE        |
test-admin-user |clients   |INSERT        |
test-admin-user |clients   |SELECT        |
test-admin-user |clients   |UPDATE        |
test-admin-user |clients   |DELETE        |
test-admin-user |clients   |TRUNCATE      |
test-admin-user |clients   |REFERENCES    |
test-admin-user |clients   |TRIGGER       |
test-simple-user|clients   |INSERT        |
test-simple-user|clients   |SELECT        |
test-simple-user|clients   |UPDATE        |
test-simple-user|clients   |DELETE        |

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
    
```sql
SELECT count(*) from clients c
```
count|
-----|
    5|
    
```sql
SELECT count(*) from orders o
```

count|
-----|
    5|

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

```sql
UPDATE clients SET order_id = (SELECT id from orders WHERE name='Книга') WHERE surname = 'Иванов Иван Иванович';
UPDATE clients SET order_id = (SELECT id from orders WHERE name='Монитор') WHERE surname = 'Петров Петр Петрович';
UPDATE clients SET order_id = (SELECT id from orders WHERE name='Гитара') WHERE surname = 'Иоганн Себастьян Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```sql
select 
	*
from 
	clients c 
```

id|surname             |country|order_id|
--|--------------------|-------|--------|
 4|Ронни Джеймс Дио    |Russia |        |
 5|Ritchie Blackmore   |Russia |        |
 1|Иванов Иван Иванович|USA    |       3|
 2|Петров Петр Петрович|Canada |       4|
 3|Иоганн Себастьян Бах|Japan  |       5|

Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

QUERY PLAN                                                |
----------------------------------------------------------|
Seq Scan on clients  (cost=0.00..10.70 rows=70 width=1040)|

- Приблизительная стоимость запуска(время, которое проходит, прежде чем начнётся этап вывода данных)
- Приблизительная общая стоимость.
- Ожидаемое число строк
- Ожидаемый средний размер строк(в байтах).

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

```
su postgres
pg_dump test_db > /tmp/testdb
exit
mv /tmp/testdb /usr/share/backup/
```
бэкап сделан пользователем рут во временную папку, и после перенесен рутом в необходимую

```
createdb -T template0 test_db
psql --set test_db < /usr/share/backup/testdb
```

```sql
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---