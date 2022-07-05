# docker build -t chrome .
# docker run --rm -it chrome
# su - user -c 'google-chrome --no-sandbox --headless --disable-gpu --screenshot https://www.chromestatus.com/'
# ls -l /home/user/screenshot.png
# su - user -c 'google-chrome --no-sandbox --headless --dump-dom https://www.chromestatus.com/'
# exit
# docker rmi chrome
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y curl
RUN mkdir -p /etc/apt/keyrings && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub -o /etc/apt/keyrings/dl.google.asc
RUN echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/dl.google.asc] http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update -y && apt-get install -y google-chrome-stable fonts-noto-cjk
RUN useradd user && install -o user -g user -d /home/user
