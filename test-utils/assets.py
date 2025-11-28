def sign_extended_bin(n, length = 32):
    if n >= 0:
        res = bin(n)[2:]
        res = (length - len(res)) * '0' + res
    
    else:
        n = -n
        res = bin(n)[2:]
        res = (length - len(res)) * '0' + res
        s = ''
        for j in res:
            if j == '0':
                s += '1'
            else:
                s += '0'
        
        res = ""
        b = False
        for j in range(len(s) - 1, -1, -1):
            if not b:
                if s[j] == '1':
                    res = '0' + res
                else:
                    res = '1' + res
                    b = True
            else:
                res = s[j] + res
    
    return res