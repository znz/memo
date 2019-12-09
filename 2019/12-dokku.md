# --force-yes

deprecate 警告が気になって、
https://github.com/jontewks/puppeteer-heroku-buildpack/pull/30/files
というのをみつけて `--allow-downgrades --allow-remove-essential --allow-change-held-packages` のようなものに変更すれば良さそうだったけど、
Debian 8 だと `--allow-*` は使えないようで、
https://wiki.debian.org/LTS
によると LTS も June 30, 2020 までだから
https://github.com/dokku/dokku/
の「Debian 8.2+ x64」も一緒に変更する必要がありそうで面倒そうだった。
