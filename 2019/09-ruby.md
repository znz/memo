# 2019-09-23

- 7zip atime で検索して `-mtc` にたどり着いて、 `7z -tzip -mx` に `-mtc=off` を足すと `7z l -slt` で見える情報のうち Created と Accessed は保存されなくなってるのは確認できたので、 `tool/make-snapshot` にも足しました。
