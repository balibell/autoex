#!/usr/bin/python3

#encoding=utf-8



import numpy as np

from PIL import Image

import glob,os,sys



picdir = sys.argv[1]
prefix = sys.argv[2]
imgsuffix = sys.argv[3]


if __name__=='__main__':

    picpre='%s/%s' % (picdir, prefix)

    files=glob.glob(picpre+'*.'+imgsuffix)

    num=len(files)

    print ("files len: %d " % num)

    filename_lens=[len(x) for x in files] #length of the files

    min_len=min(filename_lens) #minimal length of filenames

    max_len=max(filename_lens) #maximal length of filenames

    if min_len==max_len:#the last number of each filename has the same length

        files=sorted(files) #sort the files in ascending order

    else:#maybe the filenames are:x_0.png ... x_10.png ... x_100.png

        index=[0 for x in range(num)]

        for i in range(num):

            filename=files[i]

            start=filename.rfind('_')+1

            end=filename.rfind('.')

            file_no=int(filename[start:end])

            index[i]=file_no

        index=sorted(index)

        files=[picpre+'_'+str(x)+'.'+imgsuffix for x in index]



    print(files[0])

    baseimg=Image.open(files[0])

    sz=baseimg.size

    basemat=np.atleast_2d(baseimg)

    for i in range(1,num):

        file=files[i]

        im=Image.open(file)

        im=im.resize(im.size,Image.ANTIALIAS)

        mat=np.atleast_2d(im)

        print(file)

        basemat=np.append(basemat,mat,axis=0)

    final_img=Image.fromarray(basemat)

    final_img.save('%s/merged.%s' % (picdir, imgsuffix))