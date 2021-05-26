# base image
FROM ros:dashing

# update sources list
RUN apt-get clean
RUN apt-get update

# install Elixir
RUN apt-get install -y wget
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb
RUN apt-get update
RUN apt-cache showpkg elixir | grep 1.9.1
RUN apt-get install -y esl-erlang=1:22.0.7-1
RUN apt-get install -y elixir=1.9.1-1

# cleanup
RUN apt-get -qy autoremove

