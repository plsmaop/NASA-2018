#!/usr/bin/env python3
import sys
import hashlib
from Crypto import Random
from Crypto.Cipher import AES

class AESCipher(object):
    """
    A classical AES Cipher. Can use any size of data and any size of password thanks to padding.
    Also ensure the coherence and the type of the data with a unicode to byte converter.
    Source: http://depado.markdownblog.com/2015-05-11-aes-cipher-with-python-3-x
    """
    def __init__(self, key):
        self.bs = 32
        self.key = key

    @staticmethod
    def str_to_bytes(data):
        u_type = type(b''.decode('utf8'))
        if isinstance(data, u_type):
            return data.encode('utf8')
        return data

    def _pad(self, s):
        return s + (self.bs - len(s) % self.bs) * AESCipher.str_to_bytes(chr(self.bs - len(s) % self.bs))

    @staticmethod
    def _unpad(s):
        return s[:-ord(s[len(s)-1:])]

    def encrypt(self, raw):
        raw = self._pad(AESCipher.str_to_bytes(raw))
        iv = Random.new().read(AES.block_size)
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        return iv + cipher.encrypt(raw)

    def decrypt(self, enc):
        iv = enc[:AES.block_size]
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        return cipher.decrypt(enc[AES.block_size:])


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./cryptolock.py file-you-want-to-decrypt")
        exit()

    # Read file to be encrypted
    filename = sys.argv[1]
    ciphertext = open(filename, "rb").read()
    decrypted = []
    for i in range(4):
        item = []
        decrypted.append(item)

    decrypted[0].append(ciphertext)
    for level in range(4):
        for i in range(128):
            for j in range(128):
                for text in decrypted[level]:
                    key = hashlib.sha256((chr(i) + chr(j)).encode('utf-8')).digest()
                    cipher = AESCipher(key)
                    text_ = cipher.decrypt(text)
                    if level == 3:
                        print(AESCipher._unpad(text_))
                    elif ord(text_[-1:]) == 16 and ord(text_[-2:-1]) == 16:
                        decrypted[level+1].append(AESCipher._unpad(text_))
    
