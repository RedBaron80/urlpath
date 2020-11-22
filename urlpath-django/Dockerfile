FROM python:3.8.0
COPY . /opt/app
WORKDIR /opt/app
RUN make init
ENTRYPOINT [ "python","manage.py","runserver","0.0.0.0:3000" ]