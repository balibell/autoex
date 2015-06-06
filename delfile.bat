@echo off

set cmdlogin=.\qiniu\qboxrsctl
set a=38lg19V63fz9E0gAlMIFJFg5TVb-NTnGiRr0iFo4
set b=zxghXYNWf4Hd4ok8GrkDXwhf3aT5Bl4zLtvb8Tzo


if not "%1" == "" (
    echo %1
    %cmdlogin% -v login %a% %b%
    %cmdlogin% -v del balibell %1 >> log.txt
    echo delete image http://7u2o9e.com1.z0.glb.clouddn.com/%1 >> log.txt
)

