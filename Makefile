db_host=mysql
db_name=db
db_name_test=db_test
db_user=root
db_password=qwerty

init: docker-up composer-install

#all
docker-up: docker-down
	docker compose up -d --build

docker-log: docker-down
	docker compose up --build

docker-down:
	docker compose stop
	docker compose down


permission-755:
	sudo chmod -R 755 ./src/

permission-777:
	sudo chmod -R 777 ./src/

console:
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm /bin/bash

console-root:
	docker compose exec  php_fpm /bin/bash

console-node:
	docker compose exec --user $(shell id -u):$(shell id -g)  node /bin/bash

tests:
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm composer test

laravel-install-framework:
	docker compose exec --user $(shell id -u):$(shell id -g) php_fpm composer create-project --prefer-dist laravel/laravel ./
	#устанавливаем настройки базы данных
	sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/g" ./src/.env
	sed -i "s/# DB_HOST=127.0.0.1/DB_HOST=$(db_host)/g" ./src/.env
	sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=$(db_name)/g" ./src/.env
	sed -i "s/# DB_USERNAME=root/DB_USERNAME=$(db_user)/g" ./src/.env
	sed -i "s/# DB_PASSWORD=/DB_PASSWORD=$(db_password)/g" ./src/.env
	#создаем базы данных
	docker compose exec mysql mysql --user=$(db_user) --password=$(db_password) -e "CREATE DATABASE IF NOT EXISTS $(db_name) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
	docker compose exec mysql mysql --user=$(db_user) --password=$(db_password) -e "CREATE DATABASE IF NOT EXISTS $(db_name_test) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
    #выполняем миграции
	docker compose exec --user $(shell id -u):$(shell id -g) php_fpm php artisan migrate
	#устанавливаем версию php
	docker compose exec --user $(shell id -u):$(shell id -g) php_fpm composer require php
	#установка прав на папки
	-docker compose exec --user $(shell id -u):$(shell id -g) php_fpm sh -c "chmod -R 755 ./"
	-docker compose exec --user $(shell id -u):$(shell id -g) php_fpm sh -c "chmod -R 777 ./storage ./src/backend/bootstrap/cache"
	#запускаем тесты
	docker compose exec --user $(shell id -u):$(shell id -g) php_fpm php ./vendor/bin/phpunit

laravel-router-list:
	docker compose exec --user $(shell id -u):$(shell id -g) php_fpm php artisan route:list



laravel-cache-clear:
	#установка прав на папки
	-docker compose exec --user $(shell id -u):$(shell id -g) php_fpm sh -c "chmod -R 755 ./"
	-docker compose exec --user $(shell id -u):$(shell id -g) php_fpm sh -c "chmod -R 777 ./storage ./src/backend/bootstrap/cache"
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm php artisan cache:clear
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm php artisan route:clear
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm php artisan view:clear
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm php artisan config:clear
	docker compose exec --user $(shell id -u):$(shell id -g)  php_fpm php artisan config:cache
