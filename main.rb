# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'

# 共通処理
helpers do
  # XSS対策
  def escape(text)
    Rack::Utils.escape_html(text)
  end

  # DB接続
  def connection
    PG.connect(dbname: 'sinatra_memo_db')
  end

  # DBからデータを取得する処理
  def select_from_db
    connection.exec('SELECT * FROM memos ORDER BY time asc')
  end

  # DBから条件に該当するデータを取得する処理
  def select_conditionally_from_db
    connection.exec("SELECT * FROM memos WHERE id= '#{params[:id]}'")
  end

  # DBにデータを追加する処理
  def add_to_db(hash)
    connection.exec('INSERT INTO memos (id, title, body, time) VALUES ($1, $2, $3, $4)', [hash['id'], hash['title'], hash['body'], hash['time']])
  end

  # DBのデータを更新する処理
  def update_db(hash)
    connection.exec('UPDATE memos SET title= $1, body= $2 WHERE id= $3;', [hash['title'], hash['body'], hash['id']])
  end

  # DBのデータを削除する処理
  def delete_db
    connection.exec("DELETE FROM memos WHERE id= '#{params[:id]}'")
  end
end

# Topページ
get '/' do
  redirect('memos')
end

get '/memos' do
  @memos = select_from_db
  erb :top
end

# New memoページ
get '/memos/new' do
  erb :new
end

# メモの作成
post '/memos' do
  new_memo = {
    'id' => SecureRandom.uuid,
    'title' => params[:title],
    'body' => params[:body],
    'time' => Time.now
  }
  add_to_db(new_memo)
  redirect('memos')
end

# Show memoページ
get '/memos/:id' do
  @result = select_conditionally_from_db[0]
  if @result
    erb :show
  else
    erb :not_found
  end
end

# Edit memoページ
get '/memos/:id/edit' do
  @result = select_conditionally_from_db[0]
  erb :edit
end

# メモの編集
patch '/memos/:id' do
  edited_memo = {
    'id' => params[:id],
    'title' => params[:title],
    'body' => params[:body]
  }
  update_db(edited_memo)
  redirect('memos')
end

# メモを削除
delete '/memos/:id' do
  delete_db
  redirect('memos')
end

# 404ページの設定
not_found do
  erb :not_found
end
