# -*- coding:utf-8 -*-
import sys
import urllib.request

savepath = sys.argv[1]
downurl = sys.argv[2]



#proxy_handle = urllib.request.ProxyHandler({'https': 'https://127.0.0.1:25000'})
#opener = urllib.request.build_opener(proxy_handle)
#conn = opener.open(downurl)

#否则会产生无效图片
conn = urllib.request.urlopen(downurl)
f = open(savepath,'wb')
f.write(conn.read())
f.close()
print('Pic Saved!')

#print('fun name:%s' % (sys.argv[0]))
#for i in range(1, len(sys.argv)):
#    print(sys.argv[i])