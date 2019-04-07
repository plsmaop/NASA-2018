from pwn import *
import hashlib

if __name__ == "__main__":
    p = 262603487816194488181258352326988232210376591996146252542919605878805005469693782312718749915099841408908446760404481236646436295067318626356598442952156854984209550714670817589388406059285064542905718710475775121565983586780136825600264380868770029680925618588391997934473191054590812256197806034618157751903

    passwords = []
    k = random.randint(2,p)
    guess_password = 1

    while False:
        next_round = len(passwords) + 1
        if  next_round > 10:
            #for password in passwords:
                #print password
            break

        a = remote('linux13.csie.org', 7122)
        b = remote('linux13.csie.org', 7122)
        gak = 0
        gbk = 0

        for i in range(10):
            a.recvuntil('Round ', True)
            this_round = int(a.recvuntil('\n', True))

            a.recvuntil('sends: ', True)
            ga = int(a.recvuntil('\n', True))
            a.recvuntil('server: ', True)

            b.recvuntil('sends: ', True)
            gb = int(b.recvuntil('\n', True))
            b.recvuntil('server: ', True)

            if this_round != next_round:
                a.sendline(str(gb))
                b.sendline(str(ga))
                #print 'round: ', this_round, 'not this round'
                continue
            #print 'round: ', this_round

            guess_hash = int(hashlib.sha512(str(guess_password)).hexdigest(), 16)
            g = pow(guess_hash, 2, p)
            gk = pow(g, k, p)
            a.sendline(str(gk))
            b.sendline(str(gk))
            gak = int(hashlib.sha512(str(pow(ga, k, p))).hexdigest(), 16)
            gbk = int(hashlib.sha512(str(pow(gb, k, p))).hexdigest(), 16)


        a.recvuntil('FLAG is: ', True)
        b.recvuntil('FLAG is: ', True)
        FLAG_a = int(a.recvuntil('\n', True))
        FLAG_b = int(b.recvuntil('\n', True))
        a.close()
        b.close()
        FLAG_a ^= gak
        FLAG_b ^= gbk
        if FLAG_a == FLAG_b:
            passwords.append(guess_password)
            guess_password = 1
        else: 
            guess_password += 1
        if guess_password > 20:
            print 'you fucked up'
            exit()
        
    # let's crack
    key = 0
    #passwords = [15, 7, 18, 12, 3, 17, 1, 13, 9, 10]
    victim = remote('linux13.csie.org', 7122)
    for password in passwords:
        g = pow(int(hashlib.sha512(str(password)).hexdigest(), 16), 2, p)
        gk = pow(g, k, p)
        
        victim.recvuntil('sends: ', True)
        ga = int(victim.recvuntil('\n', True))
        key ^= int(hashlib.sha512(str(pow(ga, k, p))).hexdigest(), 16)

        victim.recvuntil('server: ', True)

        victim.sendline(str(gk))
    
    victim.recvuntil('FLAG is: ', True)
    flag = int(victim.recvuntil('\n', True))
    flag ^= key
    flag = hex(flag)[2:]
    print flag.decode('hex')
