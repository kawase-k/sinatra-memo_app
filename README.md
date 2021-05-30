# メモアプリ
SinatraでシンプルなWebアプリを作ろうの課題に取り組みました！

<br>

## 使い方
次のコマンドでSinatraを立ち上げてください。

```
$ bundle exec ruby main.rb 
```

<br>

## CRUD処理を実装
* メモの追加
* メモの一覧と詳細表示
* メモの更新
* メモの削除

<br>

## URL設計
| Method | Path	 | Description |
| --- | --- | --- |
| GET | /memos | Topを取得 |
| GET | /memos/new | New memoの取得 |
| POST | /memos | メモの作成 |
| GET | /memos/:id | show memoの取得 |
| GET | /memos/:id/edit | Edit memoの取得 |
| PACTH | /memos/:id | メモの編集 |
| DELETE | /memos/:id | メモを削除 |

