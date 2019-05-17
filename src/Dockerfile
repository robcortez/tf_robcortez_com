FROM lambci/lambda:build-python3.7

RUN mkdir -p /build
RUN mkdir -p /output

WORKDIR /build

COPY . .

RUN pip install -r requirements.txt -t .

RUN zip -r certbot-lambda.zip .

