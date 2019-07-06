FROM python:alpine3.7

LABEL maintainer="Hila Fish"

RUN pip3 install tweepy pymongo

COPY . /app

WORKDIR /app

ENTRYPOINT ["python3", "./twitter_streamer.py"]
