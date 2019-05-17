docker build -t lambda-builder ./src/
docker run -v ${PWD}/files:/output --rm lambda-builder cp /build/certbot-lambda.zip /output
