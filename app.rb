# -*- encoding : utf-8 -*-
require 'sinatra'
require 'haml'
require 'sinatra/twitter-bootstrap'
require_relative 'generators'   # подключаем файл с генераторами
require_relative 'lab2'
require_relative 'lab3'

set :haml, {:format => :html5, :attr_wrapper => '"'} # подключаем нужные библиотеки
register Sinatra::Twitter::Bootstrap::Assets

get '/' do  # С корневой страницы сразу переходим на 1 лабораторную
  redirect '/labs/lab1'
end

get '/labs/public/:name' do
  send_file 'public/' + params[:name], filename: params[:name] # отправляем файл пользователю
end

get '/labs/lab1' do  # Генерируем представление для 1 лабораторной
  haml :lab1
end

post '/labs/lab1' do # При нажатии на кнопку сгенерировать
  user_choise = @params["generator"].to_s # Выбранный пользователем генератор
  filename = @params["filename"].to_s # Имя файла
  n = @params["filesize"].to_i # Количество байт
  x0 = @params["first_value"].to_i # Начальное значение

  case user_choise
    when "default" # Используем стандартный генератор
      write_to_file default_generator(n), filename  # Генерируем значения и записываем результат в файл
    when "park-miller" # Используем генератор Парка-Миллера
      write_to_file park_miller_generator(n,x0,256), filename  # Генерируем значения и записываем результат в файл
    when "stop-go" # Используем генератор "Стоп-пошёл"
      $lfsr_sizes = [8, 16, 32]
      write_to_file stop_go_generator(n, x0), filename # Генерируем значения и записываем результат в файл
  end

  send_file filename, filename:filename # Отправляем файл пользователю
end

# Запись в файл
def write_to_file(arr, filename)
  result_string = ""  # обнуляем строку
  arr.each { |number| result_string << number.chr } # для каждого числа из массива генерируем символ и записываем в строку
  File.open(filename, 'w'){ |file| file.write result_string } # записываем строку в файл
end