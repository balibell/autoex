#include "IE_T2.0_4.au3"
#include <Process.au3>
#include <Date.au3>

Dim $pageurl = "https://twitter.com/fangshimin"
;$pageurl = "http://www.duitang.com"
Dim $pageurlweibo = "http://weibo.com/u/1224254755"
Dim $weibosync = False
Dim $firstRun = True
Dim $qiniuPicPre = "http://7u2o9e.com1.z0.glb.clouddn.com/"
Dim $logfile = "log.txt"
Dim $num = 0


Dim $sinaAuth = "http://dtxn.sinaapp.com/SinaOauth/index/"
Dim $sinaPost = "http://dtxn.sinaapp.com/wormhole/new_weibo/"
Dim $whichgroup = "我们(理性与人文)"
;$whichgroup = "山高高"



Func ClearHistoryAndSend()
   MouseClick("right",10,160,1)
   Sleep(500)
   MouseClick("left",30,296,1)
   Sleep(500)
   Send("{Enter}")
   Sleep(500)
   Send("{Enter}")
EndFunc

Func PostWeiboWindowMode($texten, $picurl)
   ;Return
   ; -------------------------------------------------- 同时发表微博
   ;_IEAction ($oSina, "visible")
   ;_IENavigate($oSina, $sinaPostUrl)

   Local $urlSinaShare = "http://service.weibo.com/share/share.php?title="& $texten &"&pic=" & $picurl
   Local $oSinaShare = _IECreate($urlSinaShare)
   Sleep(1000)
   js($oSinaShare,"document.getElementById('shareIt').click();")





   Local $wtit = 0
   While $wtit < 30
	  Sleep(1000)
	  ; 如果分享成功，退出循环
	  If StringInStr(_IEPropertyGet($oSinaShare,"locationurl"), "share/success.php") > -1 Then
		 ConsoleLog("=========== weibo sent ok =============")
		 ExitLoop
	  EndIf
	  $wtit += 1
   WEnd

   ; 关掉弹出的对话框
   Send("!Y")
   _IEQuit($oSinaShare)
   ; -------------------------------------------------- 发表微博结束
EndFunc





If Not WinActivate($whichgroup)  Then
   MsgBox(0, "Error", "请先打开目标聊天窗口【"& $whichgroup &"】，再执行本程序")
   Exit

EndIf


;~ Local $oIEWeibo = _IECreate($pageurlweibo)
;~ MsgBox(0,"whole thing", GetTidFromWeibo($oIEWeibo,0))

;~ Exit


MainFunc()

Exit




Func MainFunc()
   Local $oSina
   Local $oIE = _IECreate($pageurl)


   Local $oIEWeibo

   If $weibosync Then
	  $oIEWeibo = _IECreate($pageurlweibo)
   EndIf



   ;js($oIE,FileRead("jquery-2.0.2.js"))

   ; whether can get tid from html content
   Local $tid = GetTidFrom($oIE,0)
   If Not $tid  Then
	  _IEQuit($oIE)
	  Sleep(10000)
	  MainFunc()
	  Return
   EndIf








   ;记录开始时间
   Dim $timestart = _NowCalc()
   Dim $timestartwb = $timestart
   ;MsgBox(0, "timestart", $timestart)

   Dim $tick = 0
   While 1
	  ; 获取微博的权限
	  Dim $timenow = _NowCalc()
	  If _DateDiff( 's',$timestartwb,$timenow) > 36000 And False Or $firstRun And False Then
		 ; 新浪微博自动发布
		 $firstRun = False

		 _IENavigate($oSina,$sinaAuth)

		 $oSina = _IECreate($sinaAuth,1)

		 ; 点击登录授权按钮保证拿到token
		 _IENavigate($oSina,"javascript:window.location.href=document.getElementById('btngettoken').href;")

		 Local $oInputs = _IETagNameGetCollection ($oSina, "input")
		 for $oInput in $oInputs
			if $oInput.name = "userId" then
			   $oInput.Value = "243210585@qq.com"
			   ;$oInput.Value = "balibell"
			ElseIf $oInput.name = "passwd" Then
			   $oInput.Value = "lxyrw20150504"
			   ;$oInput.Value = "ea123456"
			EndIf
		 next

		 Sleep(1000)
		 Send("{Enter}")
		 $timestartwb = $timenow

		 Sleep(1000)
	  EndIf
	  ; 微博窗口暂告一段落


	  $tick += 1

	  ; 10次才做一次 $oIEWeibo 的检查
	  If Mod($tick,10) == 1 And $oIEWeibo Then
		 ; 第四个参数表示是否 weibo
		 MainSync($oIEWeibo, "oldtid_weibo.txt", 0, True)
	  EndIf

	  ; try to click new tweets bar
	  js($oIE,"$('.js-new-tweets-bar').click();$('.ProfileAvatar-container').html("& $tick &");")

	  ; if succeed num minus 1
	  If MainSync($oIE, "oldtid.txt", $num, False) And $num > 0 Then
		 $num -= 1
	  EndIf



	  ; sleep  5 secs after new tweets bar is clicked
	  Sleep(5000)

	  ; 每隔 30 分钟关闭一次浏览器抓取页面窗口
	  If _DateDiff( 's',$timestart,$timenow ) > 3600  Then
		 ; refresh page once in 1 hour
		 ;_IEAction($oIE, "refresh")

		 _IEQuit($oIE)
		 $oIE = _IECreate($pageurl)
		 $timestart = $timenow
		 $tick = 0
	  EndIf
   WEnd
EndFunc


Func MainSync($oIE, $oldtidfile, $num, $isWeibo)
   Local $tid = GetTidFrom($oIE, $num)

   If $isWeibo Then
	  $tid = GetTidFromWeibo($oIE, $num)
   EndIf

   ; read old id from file
   Local $oldTid = ReadFileValue($oldtidfile)


   ;MsgBox(0, "timestart", $oldtidfile & $oldTid & "////$tid:" & $tid)
   If $oldTid <> $tid And $tid Then
   ;If True Then
	  ; get page title
	  Local $pagetitle = js($oIE,"(document.title)")
	  WinActivate($pagetitle)
	  Sleep(2000)




	  Local $texten = js($oIE,"encodeURIComponent($('.stream-items .stream-item').eq(" & $num & ").find('.tweet-text').text().replace(/ *pic\.twitter\.com[^ ]*/,''))")
	  Local $imgurls = js($oIE,"$('.stream-items .stream-item').eq(" & $num & ").find('.cards-media-container').attr('expimgs','').find('[data-resolved-url-large]').each(function(i,e){var $t=$(e),$c=$t.closest('.cards-media-container'),imgs=$c.attr('expimgs') || '';$c.attr('expimgs', imgs+ (i == 0 ? '' : ',') + $t.attr('data-resolved-url-large'))}).closest('.cards-media-container').attr('expimgs') || ''")

	  If $isWeibo Then
		 $texten = js($oIE,"function(){var node = document.querySelector('.WB_feed_type'); if(node.getAttribute('feedtype') == 'top') node = document.querySelectorAll('.WB_feed_type:nth-of-type(2)')[0];return encodeURIComponent(node.querySelector('.WB_text').innerText)}")
		 $imgurls = js($oIE,"function(){var node = document.querySelector('.WB_feed_type'); if(node.getAttribute('feedtype') == 'top') node = document.querySelectorAll('.WB_feed_type:nth-of-type(2)')[0];var imgs = node.querySelectorAll('.media_box li img');var strimgs='';for( var i=0; i<imgs.length; i++){if(i != 0){strimgs+=','};strimgs+=imgs[i].getAttribute('src');};return strimgs;}")
	  EndIf

	  ; conversation time line
	  If Not $isWeibo And Not $imgurls Then
		 $imgurls = ConcatConversation($oIE, $num)
	  EndIf

	  Local $imgsplits = StringSplit($imgurls,",")


	  ;Local $text = _UTFToString($texten)
	  Local $text = js($oIE,"decodeURIComponent('"& $texten &"')")


	  WinActivate($whichgroup)

	  ; 切换到英文输入法，保证 send 正确 qq对话框文本输入
	  SwitchEnglish($whichgroup)
	  Sleep(500)
	  Send($text,1)



	  ConsoleLog($text)
	  ConsoleLog("imgurls ----: "& $imgurls)



	  Local $picVisPath[$imgsplits[0]]


	  ;MsgBox(0,"whole thing",$tid&$text)
	  WinSetState(_IEPropertyGet ($oIE,"hwnd"),"",@SW_MINIMIZE)

	  If $imgurls Then
		 For $si=1 To $imgsplits[0]
			Local $picSavePath = "img\tmp"& $si &".jpg"
			Local $imgurl = $imgsplits[$si]

			ConsoleLog("upload from twitter image : "& $imgurl)

			;MsgBox(0,"image exists", $imgurls)

			$picVisPath[$si-1] = GenQiuniuPath($si,"jpg")

			;Local $cmdDown = "python down.py " & $picSavePath & " " & $imgurls
			;_RunDos($cmdDown)




			Local $oImg = _IECreate($imgurl)
			; fullscreen mode in browser
			WinSetState(_IEPropertyGet ($oImg,"hwnd"),"",@SW_MAXIMIZE)
			_IEAction($oImg,"visible")
			Sleep(500)
			MouseClick("right",40,160,1)
			Sleep(500)
			Send("C")




			If Not $isWeibo Then
			   SavePictureTo($picSavePath)

			   If Not StringInStr($imgurl, $qiniuPicPre) Then
				  Local $cmdPutQiniu = "putfile "& $picVisPath[$si-1] &" " & $picSavePath
				  _RunDos($cmdPutQiniu)
			   Else
				  $picVisPath[$si-1] = StringReplace($imgurl, $qiniuPicPre,"")
			   EndIf
			EndIf



			WinActivate($whichgroup)
			Sleep(500)
			Send("^{Enter}")
			Sleep(500)
			Send("^v")

			_IEQuit($oImg)
		 Next

		 If $imgsplits[0] > 1 Then
			_RunDos("python merge.py img tmp jpg jpg")

			Local $oImgMerged = _IECreate($imgurl)
			; fullscreen mode in browser
			WinSetState(_IEPropertyGet ($oImg,"hwnd"),"",@SW_MAXIMIZE)
			_IEAction($oImg,"visible")
			Sleep(500)
			MouseClick("right",40,160,1)
			Sleep(500)
			Send("C")
		 EndIf

	  EndIf

	  ; 确认发送qq消息
	  ClearHistoryAndSend()


	  Sleep(1000)


	  ;MsgBox(0,"win active sina ", $actsn & "url:" & $text)

	  ; -------------------------------------------------- 同时发表微博
	  ;Local $sinaPostUrl = $sinaPost & "?txt=" & $texten
	  ;$sinaPostUrl &= "&img=" & $qiniuPicPre & $picVisPath[0]
	  ;_IEAction ($oSina, "visible")
	  ;_IENavigate($oSina, $sinaPostUrl)

	  If Not $isWeibo Then
		 If $imgurls Then
			PostWeiboWindowMode($texten, $qiniuPicPre & $picVisPath[0])
		 Else
			PostWeiboWindowMode($texten, "")
		 EndIf
	  EndIf



	  Sleep(1000)

	  If $imgurls Then
		 If Not $isWeibo Then
			For $si=1 To $imgsplits[0]
			   Local $cmdPutQiniu = "delfile "& $picVisPath[$si-1]
			   _RunDos($cmdPutQiniu)
			Next
		 EndIf

		 ;_RunDos("del "& @WorkingDir &"\img\*.jpg")
	  EndIf




	  ;$oldTid = $tid
	  If $tid Then
		 _RunDos("echo "& $tid &" > " & $oldtidfile)
	  EndIf

	  Return True
   EndIf

   Return False
EndFunc


; conversation time line
Func ConcatConversation($oIE, $num)
   Local $converdetail = js($oIE,"$('.stream-items .stream-item').eq(" & $num & ").find('.stream-item-footer a .Icon--conversation').closest('a').attr('href') || ''")

   ;$converdetail = "/fangshimin/status/616861782372564992"
   If $converdetail Then
	  ;MsgBox(0,"win active sina ", $converdetail)

	  Local $oIEConversation = _IECreate("http://twitter.com" & $converdetail)

	  Local $origintxt = ConversationComment($oIEConversation, 0, 1)
	  Local $replytxt = ConversationComment($oIEConversation, 1, 99)

	  Local $timeorigin = js($oIEConversation,"$('#ancestors .stream-items li.js-simple-tweet').eq(0).find('.stream-item-header ._timestamp').attr('data-time-ms') || ''")

	  Local $imgorigin = js($oIEConversation, "$($('#ancestors .stream-items li.js-simple-tweet').eq(0).find('[data-expanded-footer]').attr('data-expanded-footer')).find('[data-resolved-url-large]').attr('data-resolved-url-large') || ''")

	  ; find the original img and save it to conversation/text_3.jpg
	  If $imgorigin Then
		 Local $oIEConversationImg = _IECreate($imgorigin)

		 ; fullscreen mode in browser
		 WinSetState(_IEPropertyGet ($oIEConversationImg,"hwnd"),"",@SW_MAXIMIZE)
		 _IEAction($oIEConversationImg,"visible")

		 SavePictureTo("conversation\text_3.jpg")

		 _IEQuit($oIEConversationImg)

		 ConsoleLog($imgorigin)
	  EndIf

	  WriteConversation("conversation/text_reply_1.txt", $replytxt)
	  WriteConversation("conversation/text_origin_2.txt", $origintxt)


	  ;MsgBox(0,"reply ", $replytxt & "//time:" & $timeorigin)
	  ConsoleLog($replytxt)
	  ;MsgBox(0,"origin ", $origintxt & "//time:" & $timeorigin)
	  ConsoleLog($origintxt)
	  ConsoleLog("timestamp:" & $timeorigin)

	  Local $mergedsuffix
	  If $imgorigin Then
		 ; save jpg
		 _RunDos("python txt2im.py " & $timeorigin & " jpg")
		 _RunDos("python merge.py conversation text jpg jpg")
		 $mergedsuffix = "jpg"
	  Else
		 ; save png
		 _RunDos("python txt2im.py " & $timeorigin & " png")
		 _RunDos("python merge.py conversation text png png")
		 $mergedsuffix = "png"
	  EndIf


	  Local $qiniuImgPath = GenQiuniuPath(0, $mergedsuffix)
	  Local $cmdPutQiniu = "putfile  " & $qiniuImgPath & " conversation/merged." & $mergedsuffix
	  _RunDos($cmdPutQiniu)
	  _IEQuit($oIEConversation)

	  _RunDos("del "& @WorkingDir &"\conversation\*.jpg")
	  _RunDos("del "& @WorkingDir &"\conversation\*.png")

	  Return $qiniuPicPre & $qiniuImgPath
   EndIf
EndFunc


Func WriteConversation($sFilePath, $text)
    ; Open the file for read/write access.
    Local $hFileOpen = FileOpen($sFilePath, $FO_READ + $FO_OVERWRITE + $FO_UTF8_NOBOM )
    If $hFileOpen = -1 Then
        ConsoleLog("An error occurred when reading the file.")
        Return False
    EndIf

    ; Write some data.
    FileWrite($hFileOpen, $text)

    ; Close the handle returned by FileOpen.
    FileClose($hFileOpen)
EndFunc

Func ConversationComment($oIE, $num, $count)
   Return js($oIE,"function(){var ret='',$lis = $('#ancestors .stream-items li.js-simple-tweet').slice("&$num&","&$count&"); for(var i=0,len=$lis.length; i<len; i++){var $li = $lis.eq(i), sender = $li.find('.stream-item-header .fullname').text(), cont = $li.find('p.tweet-text').text().replace(/ *pic\.twitter\.com[^ ]*/,''); ret = '@'+sender+': '+cont + (i>0 ? '//':'') + ret}; return ret;}()")
EndFunc


Func SavePictureTo($picSavePath)
   Sleep(500)
   MouseClick("right",40,160,1)
   Sleep(500)
   Send("S")
   Sleep(1000)

   ;必须默认用英文输入法，切换有时候无用
   ;SwitchEnglish("保存图片")
   ;Sleep(500)

   Send(@WorkingDir & "\" & $picSavePath)
   Sleep(500)
   Send("{Enter}")
   Sleep(500)
   Send("!Y")
   Sleep(500)
EndFunc

Func SwitchEnglish($title)
   Local $hWnd = WinGetHandle("[ACTIVE; TITLE:"& $title &"]")
   ;MsgBox(0,"win active sina ", $hWnd & "url:" & $title)
   Local $ret = DllCall("user32.dll", "long", "LoadKeyboardLayout", "str", "08040804", "int", 1 + 0)
   DllCall("user32.dll", "ptr", "SendMessage", "hwnd", $hWnd, "int", 0x50, "int", 1, "int", $ret[0])

   Send("^+1")
EndFunc


Func GetTidFromWeibo($oIE, $num)
   return js($oIE,"(function(){var node = document.querySelector('.WB_feed_type'); return document.querySelector; if(node.getAttribute('feedtype') == 'top') node = document.querySelectorAll('.WB_feed_type:nth-of-type(2)')[0];return node.getAttribute('mid') || '';})();")
   ;return js($oIE,"(function(){var node = document.querySelector('.WB_feed_type'); if(node.getAttribute('feedtype') == 'top') node = document.querySelectorAll('.WB_feed_type:nth-of-type(2)')[0];return node.getAttribute('mid') || '';})();")
EndFunc

Func GetTidFrom($oIE, $num)
   return js($oIE,"$('.stream-items .stream-item').eq(" & $num & ").attr('data-item-id') || ''")
EndFunc


Func ReadFileValue($fileAddr)
   ; read a file
   Local $file = FileOpen($fileAddr, 0)
   Local $ret = ""

   ; 检查文件是否正常打开
   If $file = -1 Then
	   ; create this File with empty content
	   _RunDos("echo a 2> " & $fileAddr)
   Else
	  ; 每次读取1行字符直到文件结尾（EOF，End-Of-File） 为止
	  While 1
		 Local $line = FileReadLine($file)
		 If @error = -1 Then ExitLoop
		 ;MsgBox(0, "读到的文本：", $line)
		 $ret = StringReplace($line," ","")
		 ExitLoop
	  Wend
   EndIf
   FileClose($file)

   Return $ret
EndFunc


Func GenQiuniuPath($si, $suffix)
   Return "img"& $si &"/" & _DateDiff( 's',"1970/01/01 00:00:00",_NowCalc()) & "." & $suffix
EndFunc

Func ConsoleLog($text)
   _RunDos("echo %date:~0,10%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%: "  & StringRegExpReplace($text,"[&<>|]","") &" >> " & $logfile)
EndFunc

Func js($ie,$script)
  $ie.document.parentWindow.execscript("try{document.ScriptReturn=" & $script & "}catch(e){}")
  Return $ie.document.ScriptReturn
EndFunc




;~ Func _UTFToString($string)
;~    If StringInStr($string,"%")<=0 Then Return $string
;~    Local $ggeer=StringRegExp($string,"(\%[\d\w]{2})",3)
;~    If UBound($ggeer)<=1 Then Return $string
;~    Local $ls_bcbf=""
;~    For $i=0 To UBound($ggeer)-1
;~ 		   $ls_bcbf&=$ggeer[$i]
;~ 		   If $i<>UBound($ggeer)-1 Then
;~ 						   If StringInStr($string,$ls_bcbf&$ggeer[$i+1])=0 Then
;~ 										   $string=StringReplace($string,$ls_bcbf,BinaryToString("0x"&StringReplace($ls_bcbf,"%",""),4),1)
;~ 										   $ls_bcbf=""
;~ 								   EndIf
;~ 		   Else
;~ 				   If $ls_bcbf<>"" Then
;~ 				   $string=StringReplace($string,$ls_bcbf,BinaryToString("0x"&StringReplace($ls_bcbf,"%",""),4),1)
;~ 				   EndIf
;~ 		   EndIf
;~    Next
;~    Return $string
;~ EndFunc

