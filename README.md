# Sandbox для быстрого прототипирования проектов на PHP-Laravel.

# Используется: 

PHP, docker(docker-compose), nginx

# запуск

исключительно через Makefile и команду Make

# отладчик

Для отладки в PHPStorm нужно настроить PHP->servers

name: Docker

host: localhost

use path mapping: project_path/src <===> /var/www
