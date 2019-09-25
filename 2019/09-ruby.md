# 2019-09-25

```
% cat a.c
#include <stdio.h>

int
main() {
  printf("\e\n");
  return 0;
}
% gcc -std=c89 -pedantic a.c
a.c:5:11: warning: use of non-standard escape character '\e' [-Wpedantic]
  printf("\e\n");
          ^~
1 warning generated.
```

# 2019-09-23

- 7zip atime で検索して `-mtc` にたどり着いて、 `7z -tzip -mx` に `-mtc=off` を足すと `7z l -slt` で見える情報のうち Created と Accessed は保存されなくなってるのは確認できたので、 `tool/make-snapshot` にも足しました。
