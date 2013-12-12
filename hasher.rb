# -*- encoding : utf-8 -*-
require 'digest/md5'

HASH_LENGTH = 32
BYTES_COUNT = 10
FIRST_LETTER = 0
ALPH = 255

# Реализация Хэш-функции
def hash_function(pass)
  hash = 0
  pass.each_byte do |byte| # каждый байт пароля
    hash^= byte # складываем по модулю 2 с хэш функцией
    hash*= byte # и умножаем хэш функцию на каждый байт
  end

  if hash > 10**HASH_LENGTH
    hash = hash % (10**HASH_LENGTH)
  else
    hash *= 10**(HASH_LENGTH - (Math.log10(hash).to_int + 1))
  end
  hash
end

def get_check_sum(text)
  Digest::MD5.hexdigest text
end

def vigenere(text,key, encrypt = true)
  result = ''
  text = text.each_byte.to_a
  key = key.each_byte.to_a
  if encrypt
    0.upto(text.length - 1) do |i|
      result << ((text[i] + key[(i % key.length)] - 2 * FIRST_LETTER) % ALPH + FIRST_LETTER).chr
    end
  else
    0.upto(text.length - 1) do |i|
      result << ((text[i] - key[(i % key.length)] + ALPH) % ALPH + FIRST_LETTER).chr
    end
  end
  result
end

# сеть Фейстала
def feistel(left, right, encode = true)
  round = (encode)? [1, 2, 3] : [3, 2, 1]
  for i in 0 .. 1
    temp = left.dup
    left.each_index { |j| left[j] = (right[j] ^ (left[j] + round[i])) % 256 }
    right = temp.dup
  end
  right.each_index {  |j| right[j] = (right[j] ^ (left[j] + round[2])) % 256 }
  [left, right]
end

def encode(text, password)
  result = vigenere(text, password, true)
  if $use_feistel
    blocks = []
    result.bytes.to_a.each_slice(BYTES_COUNT) {|a| blocks << a}
    ostatok = (blocks[-1].size == BYTES_COUNT) ? [] : blocks.pop

    blocks_encrypted = []
    blocks.each { |block| blocks_encrypted << feistel(block[0..4], block[5..9], true).flatten}

    bytes_final = blocks_encrypted.flatten + ostatok
    result = ''
    bytes_final.each { |byte| result << byte.chr}
  end
  result
end

def decode(text, password)
  if $use_feistel
    blocks = []
    text.bytes.to_a.each_slice(BYTES_COUNT) {|a| blocks << a}
    ostatok = (blocks[-1].size == BYTES_COUNT) ? [] : blocks.pop

    blocks_encrypted = []
    blocks.each { |block| blocks_encrypted << feistel(block[0..4], block[5..9], false).flatten}

    bytes_final = blocks_encrypted.flatten + ostatok
    result = ''
    bytes_final.each { |byte| result << byte.chr}
    vigenere(result, password, false)
  else
    vigenere(text, password, false)
  end
end