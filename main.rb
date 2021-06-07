# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

# 共通処理
helpers do
  # jsonファイルを作成日順に並び替えて、ファイルの中身をhashに変換する処理
  def fetch_memos_from_json_file
    json_files = Dir.glob('json/*').sort_by { |file| File.birthtime(file) }
    json_files.map { |file| JSON.parse(File.read(file)) }
  end

  # XSS対策
  def escape(text)
    Rack::Utils.escape_html(text)
  end

  # hashからjson形式に変換する処理
  def write_to_json_file(hash)
    File.open("json/#{hash['id']}.json", 'w') do |file|
      JSON.dump(hash, file)
    end
  end
end

# Topページ
get '/' do
  redirect('memos')
end

get '/memos' do
  @memos = fetch_memos_from_json_file
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
    'body' => params[:body]
  }
  write_to_json_file(new_memo)
  redirect('memos')
end

# Show memoページ
get '/memos/:id' do
  id = params[:id]
  @result = fetch_memos_from_json_file.find { |x| x['id'].include?(id) }
  if @result
    erb :show
  else
    erb :not_found
  end
end

# Edit memoページ
get '/memos/:id/edit' do
  id = params[:id]
  @result = fetch_memos_from_json_file.find { |x| x['id'].include?(id) }
  erb :edit
end

# メモの編集
patch '/memos/:id' do
  edited_memo = {
    'id' => params[:id],
    'title' => params[:title],
    'body' => params[:body]
  }
  write_to_json_file(edited_memo)
  redirect('memos')
end

# メモを削除
delete '/memos/:id' do
  File.delete("json/#{params[:id]}.json")
  redirect('memos')
end

# 404ページの設定
not_found do
  erb :not_found
end
