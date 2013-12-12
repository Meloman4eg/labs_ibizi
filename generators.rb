# -*- encoding : utf-8 -*-

CONST_A = 16807 # 7**5 # Для генератора Парка-Миллера
CONST_M = 2147483647 # 2**31 - 1 # Для генератора Парка-Миллера

#Стандартный генератор
def default_generator(bytes_count)
  result = [] # обнуляем массив
  srand # включаем генератор
  bytes_count.times do #
    number = rand(256) # генерируем число в диапазоне от 0 до 255
    result << number   # записываем число в массив
  end
  result # возвращаем массив сгенерированных чисел
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

# Работа одного регистра LFSR
def lfsr(num, clocking)
  high_bit = ($lfsr_registers[num] / 2**($lfsr_sizes[num] - 1)) == 1  # получаем старший бит
  next_bit = high_bit ^ ($lfsr_registers[num] % 2 == 1) # генерируем следующий бит с помощью XOR
  if clocking # если нужен сдвиг регистра
    $lfsr_registers[num] = $lfsr_registers[num] % (2**($lfsr_sizes[num] - 1)) * 2  # осуществляем сдвиг
    $lfsr_registers[num]+=1 if next_bit    # запись в младший разряд 1, если next_bit == TRUE
  end
  high_bit # возвращаем старший бит
end

# Генератор "Стоп-пошёл"
def stop_go_generator(bytes_count, x0)
  $lfsr_registers = []
  # генерируем начальные значения регистров с помощью генератора Парка-Миллера
  0.upto(2) { |i| $lfsr_registers[i] = park_miller_generator(1, x0,(2**$lfsr_sizes[i]))[0] }
  result = [] # обнуляем массив
  bytes_count.times do
    symbol = 0 # обнуляем текущий байт
    8.times do # 8 раз генерирум бит
      symbol *= 2 # сдвигаем заполняемый бит
      symbol += 1 if (! ((lfsr(2, true)) || (lfsr(1, (lfsr(0,true)))) )) # по формуле генирируем бит
    end
    result << symbol # записываем байт в массив
  end
  result # возвращаем массив сгенерированных чисел
end