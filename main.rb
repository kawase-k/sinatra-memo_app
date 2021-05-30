# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

# 共通処理
helpers do
  # jsonファイルを作成日順に並び替えて、ファイルの中身をhashに変換する処理
  def sort_and_convert_to_hash
    json_files = Dir.glob('json/*').sort_by { |file| File.birthtime(file) }
    @hash_files = json_files.map { |file| JSON.parse(File.read(file)) }
  end

  # XSS対策
  def escape(text)
    Rack::Utils.escape_html(text)
  end

  # hashからjson形式に変換する処理
  def convert_to_json(hash)
    File.open("json/#{hash['id']}.json", 'w') do |file|
      JSON.dump(hash, file)
    end
  end
end

# Topページ
get '/memos' do
  sort_and_convert_to_hash
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
  convert_to_json(new_memo)
  redirect('memos')
end

# Show memoページ
get '/memos/:id' do
  id = params[:id]
  @result = sort_and_convert_to_hash.find { |x| x['id'].include?(id) }
  erb :show
end

# Edit memoページ
get '/memos/:id/edit' do
  id = params[:id]
  @result = sort_and_convert_to_hash.find { |x| x['id'].include?(id) }
  erb :edit
end

# メモの編集
patch '/memos/:id' do
  edited_memo = {
    'id' => params[:id],
    'title' => params[:title],
    'body' => params[:body]
  }
  convert_to_json(edited_memo)
  redirect('memos')
end

# メモを削除
delete '/memos/:id' do
  File.delete("json/#{params[:id]}.json")
  redirect('memos')
end
