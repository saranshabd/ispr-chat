buildnstart:
	docker build -t papercups . \
		--build-arg ALLOWED_ORIGINS=http://localhost:3000 \
		--build-arg COOKIE_SIGNING_SALT=QvEKzv2I \
		--build-arg COOKIE_ENCRYPTION_SALT=cEm23d4pl
	docker-compose up
