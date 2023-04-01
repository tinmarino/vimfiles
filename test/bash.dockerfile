FROM ubuntu:latest

RUN apt update

RUN apt install -y git
RUN apt install -y vim

RUN unlink /root/.bashrc
