provider "yandex" {
  token     = "${var.token}"
  cloud_id  = "${var.cloud_id}"
  folder_id = "${var.folder_id}"
  zone      = "${var.zone}"
}

resource "yandex_compute_image" "foo-image" {
  name       = "my-custom-image"
  source_url = "https://storage.yandexcloud.net/lucky-images/kube-it.img"
}

resource "yandex_compute_instance" "vm" {
  name = "vm-from-custom-image"

  # ...

  resources {
    cores         = "2"
    memory        = "1"
    core_fraction = "20"
  }
  network_interface {
    subnet_id = "${var.folder_id}"
    nat       = "true"
  }
  boot_disk {
    initialize_params {
      image_id = "fd8gu48shgedqb1ubago"
      type = "network-hdd"
      size = "5"
    }
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
