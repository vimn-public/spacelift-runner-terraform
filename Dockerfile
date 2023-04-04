FROM public.ecr.aws/spacelift/runner-terraform:latest

WORKDIR /tmp

ADD files/state-credentials.tf /usr
ADD files/before_init /usr/local/bin

