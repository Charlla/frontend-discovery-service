.PHONY: up-local down-local deploy-local build test clean

# Start LocalStack
up-local:
	docker-compose up -d
	sleep 10
	terraform init
	terraform apply -auto-approve

# Stop LocalStack and clean up
down-local:
	docker-compose down
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
	rm -rf volume

# Build Lambda functions
build:
	npm install
	rm -rf dist
	mkdir -p dist/stream dist/consumerApi dist/adminApi
	npx esbuild infrastructure/lambda/stream/app.js --bundle --platform=node --target=node16 --outdir=dist/stream
	npx esbuild infrastructure/lambda/consumerApi/app.js --bundle --platform=node --target=node16 --outdir=dist/consumerApi
	npx esbuild infrastructure/lambda/adminApi/app.js --bundle --platform=node --target=node16 --outdir=dist/adminApi
	cd dist/stream && zip -r app.zip * && cd ../..
	cd dist/consumerApi && zip -r app.zip * && cd ../..
	cd dist/adminApi && zip -r app.zip * && cd ../..

# Deploy to LocalStack
deploy-local: build
	terraform apply -auto-approve

# Run tests
test:
	npm test

# Clean up
clean:
	rm -rf dist
	rm -rf node_modules
	rm -rf .terraform*
	rm -rf terraform.tfstate*
	rm -rf volume