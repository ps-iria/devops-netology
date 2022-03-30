# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 


## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.

```shell script
$ terraform workspace list
  default
* prod
  stage
```
* Вывод команды `terraform plan` для воркспейса `prod`.  


```shell script

$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_image.foo-image will be created
  + resource "yandex_compute_image" "foo-image" {
      + created_at      = (known after apply)
      + folder_id       = (known after apply)
      + id              = (known after apply)
      + min_disk_size   = (known after apply)
      + name            = "my-custom-image"
      + os_type         = (known after apply)
      + pooled          = (known after apply)
      + product_ids     = (known after apply)
      + size            = (known after apply)
      + source_disk     = (known after apply)
      + source_family   = (known after apply)
      + source_image    = (known after apply)
      + source_snapshot = (known after apply)
      + source_url      = "https://storage.yandexcloud.net/lucky-images/kube-it.img"
      + status          = (known after apply)
    }

  # yandex_compute_instance.vm[0] will be created
  + resource "yandex_compute_instance" "vm" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2NSTHCchotKkzOSJyp4qcjPVikLv7qWT3HELZvEYlQoFrm2W42ssV09ZujbvpVJJdQj8FmAw/FVC0+cVR1CS2HQNyf
Ybt6fduF+Npx6M/iRJaRtZxj+fkwyIHM0okypWWiiLpS6FXLEzPph76LrWojpi2dX/dOnycjltjawFWGqHlkcX6zbMFWEtLenss5EQCwFObLHeqZl6rkWRLIAyMrX4NRgkBx6K1b0cXexrvKiuU+Q5DJ
LG7BXHecIqmh3olEomWen3hzzO36JVudoffW6TF3CCiNhLuV+OCN4MtHrWwG4qpWSzRzjyLb6DMKVavU0SNcOJVhGZofj3+KNmNq+MXq3JHLq6acT+Ktr5tdhnT0jMFl4CdWscB2VrNRUKJeFLSK3+e1
d+FiakRr5RkqFP5V/p3wXlTxKLzmYSM0UEbKqx1bsHMcstG4TDifhYqogep6spnVNDGlhQUl82ndh2dBotiqubROjLYjJ1XY07sfBNk5VmMBRJACfuvTV0= drpsy@PS
            EOT
        }
      + name                      = "vm-from-custom-image"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8gu48shgedqb1ubago"
              + name        = (known after apply)
              + size        = 5
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "b1gk97hnm8qhvnu6puut"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm[1] will be created
  + resource "yandex_compute_instance" "vm" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2NSTHCchotKkzOSJyp4qcjPVikLv7qWT3HELZvEYlQoFrm2W42ssV09ZujbvpVJJdQj8FmAw/FVC0+cVR1CS2HQNyf
Ybt6fduF+Npx6M/iRJaRtZxj+fkwyIHM0okypWWiiLpS6FXLEzPph76LrWojpi2dX/dOnycjltjawFWGqHlkcX6zbMFWEtLenss5EQCwFObLHeqZl6rkWRLIAyMrX4NRgkBx6K1b0cXexrvKiuU+Q5DJ
LG7BXHecIqmh3olEomWen3hzzO36JVudoffW6TF3CCiNhLuV+OCN4MtHrWwG4qpWSzRzjyLb6DMKVavU0SNcOJVhGZofj3+KNmNq+MXq3JHLq6acT+Ktr5tdhnT0jMFl4CdWscB2VrNRUKJeFLSK3+e1
d+FiakRr5RkqFP5V/p3wXlTxKLzmYSM0UEbKqx1bsHMcstG4TDifhYqogep6spnVNDGlhQUl82ndh2dBotiqubROjLYjJ1XY07sfBNk5VmMBRJACfuvTV0= drpsy@PS
            EOT
        }
      + name                      = "vm-from-custom-image"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8gu48shgedqb1ubago"
              + name        = (known after apply)
              + size        = 5
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "b1gk97hnm8qhvnu6puut"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm2["prod"] will be created
  + resource "yandex_compute_instance" "vm2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2NSTHCchotKkzOSJyp4qcjPVikLv7qWT3HELZvEYlQoFrm2W42ssV09ZujbvpVJJdQj8FmAw/FVC0+cVR1CS2HQNyf
Ybt6fduF+Npx6M/iRJaRtZxj+fkwyIHM0okypWWiiLpS6FXLEzPph76LrWojpi2dX/dOnycjltjawFWGqHlkcX6zbMFWEtLenss5EQCwFObLHeqZl6rkWRLIAyMrX4NRgkBx6K1b0cXexrvKiuU+Q5DJ
LG7BXHecIqmh3olEomWen3hzzO36JVudoffW6TF3CCiNhLuV+OCN4MtHrWwG4qpWSzRzjyLb6DMKVavU0SNcOJVhGZofj3+KNmNq+MXq3JHLq6acT+Ktr5tdhnT0jMFl4CdWscB2VrNRUKJeFLSK3+e1
d+FiakRr5RkqFP5V/p3wXlTxKLzmYSM0UEbKqx1bsHMcstG4TDifhYqogep6spnVNDGlhQUl82ndh2dBotiqubROjLYjJ1XY07sfBNk5VmMBRJACfuvTV0= drpsy@PS
            EOT
        }
      + name                      = "vm-from-custom-image"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8gu48shgedqb1ubago"
              + name        = (known after apply)
              + size        = 5
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "b1gk97hnm8qhvnu6puut"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm2["stage"] will be created
  + resource "yandex_compute_instance" "vm2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2NSTHCchotKkzOSJyp4qcjPVikLv7qWT3HELZvEYlQoFrm2W42ssV09ZujbvpVJJdQj8FmAw/FVC0+cVR1CS2HQNyf
Ybt6fduF+Npx6M/iRJaRtZxj+fkwyIHM0okypWWiiLpS6FXLEzPph76LrWojpi2dX/dOnycjltjawFWGqHlkcX6zbMFWEtLenss5EQCwFObLHeqZl6rkWRLIAyMrX4NRgkBx6K1b0cXexrvKiuU+Q5DJ
LG7BXHecIqmh3olEomWen3hzzO36JVudoffW6TF3CCiNhLuV+OCN4MtHrWwG4qpWSzRzjyLb6DMKVavU0SNcOJVhGZofj3+KNmNq+MXq3JHLq6acT+Ktr5tdhnT0jMFl4CdWscB2VrNRUKJeFLSK3+e1
d+FiakRr5RkqFP5V/p3wXlTxKLzmYSM0UEbKqx1bsHMcstG4TDifhYqogep6spnVNDGlhQUl82ndh2dBotiqubROjLYjJ1XY07sfBNk5VmMBRJACfuvTV0= drpsy@PS
            EOT
        }
      + name                      = "vm-from-custom-image"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8gu48shgedqb1ubago"
              + name        = (known after apply)
              + size        = 5
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "b1gk97hnm8qhvnu6puut"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

Plan: 5 to add, 0 to change, 0 to destroy.
╷
│ Warning: Value for undeclared variable
│
│ The root module does not declare a variable named "project" but a value was found in file "terraform.tfvars". If you meant to use this value, add a
│ "variable" block to the configuration.
│
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all configurations in your organization. To
│ reduce the verbosity of these warnings, use the -compact-warnings option.
╵

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.


```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---