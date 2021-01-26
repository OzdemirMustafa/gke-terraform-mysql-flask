FROM python:3.9-alpine

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt ./requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /src
COPY . /src

RUN adduser -D user
USER user

EXPOSE 5000
CMD ["python", "serve.py"]


