@echo off

set cmdlogin=.\qiniu\qboxrsctl
set a=38lg19V63fz9E0gAlMIFJFg5TVb-NTnGiRr0iFo4
set b=zxghXYNWf4Hd4ok8GrkDXwhf3aT5Bl4zLtvb8Tzo





if not "%1" == "" if not "%2" == "" (
    echo %1 %2
    %cmdlogin% -v login %a% %b%
    %cmdlogin% -v put -c  balibell %1 %2 >> log.txt
    echo http://7u2o9e.com1.z0.glb.clouddn.com/%1 >> log.txt
)

