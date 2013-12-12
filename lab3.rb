# -*- encoding : utf-8 -*-
require_relative 'hasher'

get '/labs/lab3' do  # Генерируем представление для 3 лабораторной
  @visible_a = false
  haml :lab3
end

post '/labs/lab3' do  # Обрабатываем
  filename = 'public/' + params['f'][:filename] # получаем имя файла из POST-запроса
  File.open(filename, 'w') {|f| f.write(params['f'][:tempfile].read) } # Получаем сам переданный файл
  filecontent = File.open(filename){ |file| file.read } # читаем содержимое файла

  pass  = params['pass'] # получаем пароль

  encrypte = (params['encode_type'] == 'encode')
  @crypte_status = (encrypte) ? 'Было выбрано кодирование' : 'Было выбрано декодирование'

  $use_feistel = (params['mode'] == 'feistel')
  @mode = ($use_feistel) ? "Был выбран режим 'Сеть Фейстела'" : "Был выбран режим ECB"

  filename_output = 'public/' + 'coded_' + params['f'][:filename]
  @filename = filename_output
  if encrypte # кодирование
    hash_of_pass = hash_function(pass)

    begin_time = Time.now
    encoded_text = encode(filecontent, pass)
    end_time = Time.now
    speed = encoded_text.bytesize / (end_time - begin_time)
    @status = 'Файл успешно зашифрован!'
    @speed_stat = "Скорость шифрования: #{speed.to_i} символов в секунду"

    check_sum = get_check_sum (encoded_text)
    File.open(filename_output, 'w') do |file|
      file.write hash_of_pass
      file.write check_sum
      file.write encoded_text
    end
    @visible_a = true
    haml :lab3

  else # декодирование
    hash_of_pass, check_sum, coded_text = filecontent[0..31], filecontent[32..63], filecontent[64..-1]
    if check_sum != get_check_sum(coded_text)
      @error =  'Неправильная контрольная сумма файла!'
      haml :lab3
    elsif hash_of_pass.to_i != hash_function(pass)
      @error = 'Неверный пароль!'
      haml :lab3
    else
      begin_time = Time.now
      decoded_text = decode(coded_text, pass)
      end_time = Time.now
      speed = decoded_text.bytesize / (end_time - begin_time)
      @status =  'Файл успешно расшифрован!'
      @speed_stat = "Скорость шифрования: #{speed.to_i} символов в секунду"

      File.open(filename_output, 'w') { |file| file.write decoded_text}
      @visible_a = true
      haml :lab3
    end
  end
end