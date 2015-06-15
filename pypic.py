# -*- coding:utf-8 -*-

import os
import pygame
from pygame.locals import *

pygame.init()

text = u"今天把一个列表转换成 字符串输 出的时候出现了UnicodeEncodeError: 'ascii' codec can't encode characters in position 32-34: ordinal not in range(128)问题，使用的是ulipad编译器。这是一段测试文本，test 123。"
font = pygame.font.SysFont('SimHei', 14)
ftext = font.render(text, True, (0, 0, 0), (255, 255, 255))

pygame.image.save(ftext, "tmp/t.jpg")