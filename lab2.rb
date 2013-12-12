# -*- encoding : utf-8 -*-

get '/labs/lab2' do  # Генерируем представление для 2 лабораторной
  @visible_a = false
  haml :lab2
end

post '/labs/lab2' do  # Обрабатываем
  filename = 'public/' + params['f'][:filename] # получаем имя файла из POST-запроса
  File.open(filename, "w") {|f| f.write(params['f'][:tempfile].read) } # Получаем сам переданный файл

  password  = params['pass'] # получаем пароль
  hash = hash_function(password) # вычисляем хэш-функцию

  begin_time = Time.now # замеряем текущее время
  bytescount = encrypt_file(filename, hash) # шифруем файл, получаем количество байт в файле
  end_time = Time.now # замеряем текущее время

  speed = bytescount / (end_time -begin_time) # вычисляем скорость шифрования
  @visible_a = true
  @filename = filename
  @speed_stat = "Файл успешно зашифрован! Скорость шифрования: #{speed} б/c"
  haml :lab2
end

#Генератор Парка-Миллера
def park_miller_generator( bytes_count, x0, max_value)
  x = x0 #в x записываем начальное значение от пользователя
  result = [] # обнуляем массив
  bytes_count.times do
    current_x = (CONST_A*x) % CONST_M # генерируем следующее значение
    result << current_x % max_value  # записываем в массив сгенерированное значение в диапазоне от 0 до 255
    x = current_x # запоминаем сгенерированное значение для вычисления следующего
  end
  result # возвращаем массив сгенерированных чисел
end

# Реализация Хэш-функции
def hash_function(pass)
  hash = 0
  pass.each_byte do |byte| # каждый байт пароля
    hash^= byte # складываем по модулю 2 с хэш функцией
    hash*= byte # и умножаем хэш функцию на каждый байт
  end
  hash  # возвращаем хэш
end

# Шифрование файла
def encrypt_file(filename, hash)
  filecontent = File.open(filename){ |file| file.read } # читаем содержимое файла
  mask = park_miller_generator( filecontent.bytesize, hash, 256) # генерируем гамму с помощью хэша и генератора Парка-Миллера
  buffer = filecontent.each_byte.to_a # получаем содержимое файла в числовом виде

  0.upto(buffer.length - 1) { |num| buffer[num] = buffer[num] ^ mask[num] } # выполняем гаммирование, делая XOR

  result_str = ""
  buffer.each {|num| result_str << num.chr  } # записываем полученные байты в строку

  File.open(filename, 'w'){ |file| file.write result_str }  # записываем полученную строку в файл
  filecontent.bytesize # возвращаем количество байт в файле
end