# docker build -t chrome .
# docker run --rm -it chrome
# su - user -c 'google-chrome --no-sandbox --headless --disable-gpu --screenshot https://www.chromestatus.com/'
# su - user -c 'google-chrome --no-sandbox --headless --dump-dom https://www.chromestatus.com/'
# docker rmi chrome
FROM ubuntu:22.04
RUN apt-get update -y && apt-get install -y curl
RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub -o /etc/apt/trusted.gpg.d/packages.google.asc
RUN echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.google.asc] http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update -y && apt-get install -y google-chrome-stable fonts-noto-cjk
RUN useradd user && install -o user -g user -d /home/user
