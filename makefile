inithost:
    sudo apt update && apt upgrade
	@make installnpm
	@make installdocker

## ref https://zenn.dev/taiga533/articles/11f1b21ef4a5ff
# インストールに必要なものをインストール
# GPGキー追加
# dockerのパッケージリポジトリをaptに追加
# dockerEngineのインストール
# docker-composeのインストール

installdocker:
    sudo apt update && apt upgrade
	@make installnpm
	sudo apt install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt install docker-ce docker-ce-cli containerd.io
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

# docker daemonの起動
## ref https://zenn.dev/taiga533/articles/11f1b21ef4a5ff

#sudo visudo
# ユーザー名 ALL=NOPASSWD: /usr/sbin/service docker start, /usr/sbin/service docker stop, /usr/sbin/service docker restart
#vi .bashrc
# #for local docker
# service docker status > /dev/null 2>&1
# if [ $? = 3 ]; then
#     sudo service docker start
# fi

#ユーザーをdockerグループに所属させる。
#sudo usermod -aG docker $USER
docker:
	sudo service docker start

installnpm:
# nを入れるために、一旦aptでnodeをインストール
	sudo apt install nodejs npm
# nをグローバルにインストール
	sudo npm install -g n
# LTSバージョンをインストール
	sudo n lts
# aptで入れたnodeを削除
	sudo apt purge nodejs npm

## 初回実行コマンド
init:
	@make githook-init
	docker-compose up --build -d
	docker-compose exec --user 1000 app cp .env.example .env
	docker-compose exec app composer install
	@make chmod
	docker-compose exec app php artisan key:generatedocker
	docker-compose exec app php artisan jwt:secret
	docker-compose exec app php artisan storage:link
	docker-compose exec --user 1000 app cp /var/www/html/storage/fonts/BIZUDPGothic-Regular.ttf /var/www/html/vendor/mpdf/mpdf/ttfonts/
	@make fresh

githook-init:
	git config core.hooksPath .git-hooks
	chmod +x .git-hooks/*

chmod:
	chmod +x php.sh
	chmod +x phpstan.sh
	docker-compose exec app chmod -R 777 /var/log/uptalk
	docker-compose exec app chmod -R 777 /var/www/html/storage/clockwork
	docker-compose exec app chmod -R 777 /var/www/html/storage/framework
	docker-compose exec app chmod -R 777 /var/www/html/storage/debugbar
	docker-compose exec app chmod -R 777 /var/www/html/storage/logs
	docker-compose exec app chmod -R 777 /var/www/html/storage/app
	docker-compose exec app chmod -R 777 /var/www/html/storage/app/public
	docker-compose exec app chmod -R 777 /var/www/html/vendor/mpdf/mpdf

## 全テーブル再作成＋初期データ作成
fresh:
	docker-compose exec app php artisan migrate:fresh --seed