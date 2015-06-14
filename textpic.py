# -*- coding:utf-8 -*-
import sys


from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

import uuid


reload(sys)
sys.setdefaultencoding( "utf-8" )

def text2png(text):
    # config:
    adTexts = ['---------------', 'http://www.planabc.net']
    imgBg = '#FFFFFF'
    textColor = "#000000"
    adColor = "#FF0000"
    ttf = "fonts\Zfull-GB.ttf"
    fontSize = 20
    tmp = 'tmp/'

    # Build rich text for ads
    ads = []
    for adText in adTexts:
        ads += [(adText.decode('utf-8'), adColor)]
    # Format wrapped lines to rich text

    bodyTexts = [""]
    l = 0
    # x.decode() ==> unicode

    for character in text.decode('utf-8'):
        c = character
        delta = len(c)
        if c == '\n':
            bodyTexts += [""]
            l = 0
        elif l + delta > 40:
            bodyTexts += [c]
            l = delta
        else:
            bodyTexts[-1] += c
            l += delta

    body = [(text, textColor) for text in bodyTexts]
    body += ads

    # Draw picture
    img = Image.new("RGB", (530, len(body) * fontSize + 5), imgBg)

    # Ref: http://blog.163.com/zhao_yunsong/blog/static/34059309200762781023987/

    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype(ttf, fontSize)

    for num, (text, color) in enumerate(body):
        draw.text((2, fontSize * num), text, font=font, fill=color)


    # Write result to a temp file

    # filename = uuid.uuid4().hex + ".png"
    filename = "textpic.png"

    file = open(tmp + filename, "wb")
    img.save(file, "PNG")

    return tmp + filename


if __name__ == '__main__':
    text2png(u"今天把一个列表转换成字符串输出的时候出现了UnicodeEncodeError: 'ascii' codec can't encode characters in position 32-34: ordinal not in range(128)问题，使用的是ulipad编译器。")