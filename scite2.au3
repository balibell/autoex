#include "IE_T2.0_4.au3"
#include <Process.au3>
#include <Date.au3>

Dim $pageurl = "https://twitter.com/fangshimin"
;$pageurl = "http://www.duitang.com"
Dim $sinaAuth = "http://dtxn.sinaapp.com/SinaOauth/index/"
Dim $sinaPost = "http://dtxn.sinaapp.com/wormhole/new_weibo/"
Dim $whichgroup = "����(����������)"
;$whichgroup = "ɽ�߸�"
Dim $oldtidfile = "oldtid.txt"
Dim $logfile = "log.txt"
Dim $num = 0
Dim $tick = 0
Dim $firstRun = True







If Not WinActivate($whichgroup)  Then
   MsgBox(0, "Error", "���ȴ�Ŀ�����촰�ڡ�"& $whichgroup &"������ִ�б�����")
   Exit
EndIf


MainFunc()

Exit




Func MainFunc()
   Local $oSina
   Local $oIE = _IECreate($pageurl)
   ;js($oIE,FileRead("jquery-2.0.2.js"))

   ; whether can get tid from html content
   Local $tid = GetTidFrom($oIE,0)
   If Not $tid  Then
	  _IEQuit($oIE)
	  Sleep(10000)
	  MainFunc()
	  Return
   EndIf




   ; get page title
   Local $pagetitle = js($oIE,"(document.title)")
   ;MsgBox(0, "title", $pagetitle)

   ; read old id from file
   Local $oldTid = ReadFileValue($oldtidfile)


   ;��¼��ʼʱ��
   Dim $timestart = _NowCalc()
   Dim $timestartwb = $timestart
   ;MsgBox(0, "timestart", $timestart)




   While 1
	  ; ��ȡ΢����Ȩ��
	  Dim $timenow = _NowCalc()
	  If _DateDiff( 's',$timestartwb,$timenow) > 36000 And False Or $firstRun And False Then
		 ; ����΢���Զ�����
		 $firstRun = False

		 _IENavigate($oSina,$sinaAuth)

		 $oSina = _IECreate($sinaAuth,1)

		 ; �����¼��Ȩ��ť��֤�õ�token
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
	  ; ΢�������ݸ�һ����


	  $tick += 1
	  ; try to click new tweets bar
	  js($oIE,"$('.js-new-tweets-bar ').click();$('.ProfileAvatar-container').html("& $tick &");")

	  $tid = GetTidFrom($oIE, $num)
	  ;MsgBox(0, $tick & "whole thing",$tid)


	  If $oldTid <> $tid And $tid Then
	  ;If True Then
		 WinActivate($pagetitle)
		 Sleep(2000)




		 Local $texten = js($oIE,"encodeURIComponent($('.stream-items .stream-item').eq(" & $num & ").find('.tweet-text').text().replace(/ *pic\.twitter\.com.*/,''))")
		 Local $imgurls = js($oIE,"$('.stream-items .stream-item').eq(" & $num & ").find('.cards-media-container').attr('expimgs','').find('[data-resolved-url-large]').each(function(i,e){var $t=$(e),$c=$t.closest('.cards-media-container'),imgs=$c.attr('expimgs') || '';$c.attr('expimgs', imgs+ (i == 0 ? '' : ',') + $t.attr('data-resolved-url-large'))}).closest('.cards-media-container').attr('expimgs') || ''")
		 Local $imgsplits = StringSplit($imgurls,",")


		 ;Local $text = _UTFToString($texten)
		 Local $text = js($oIE,"decodeURIComponent('"& $texten &"')")


		 WinActivate($whichgroup)
		 Send("^+1")
		 Sleep(500)
		 Send($text,1)


		 _RunDos("echo "& StringRegExpReplace($text,"[&<>|]","") &" >> " & $logfile)
		 _RunDos("echo imgurls ----: "& $imgurls &" >> " & $logfile)


		 Local $picVisPath[$imgsplits[0]]
		 Local $picVisPre = "http://7u2o9e.com1.z0.glb.clouddn.com/"

		 ;MsgBox(0,"whole thing",$tid&$text)
		 WinSetState(_IEPropertyGet ($oIE,"hwnd"),"",@SW_MINIMIZE)

		 If $imgurls Then
			For $si=1 To $imgsplits[0]
			   Local $picSavePath = "img\tmp"& $si &".jpg"
			   Local $imgurl = $imgsplits[$si]
			   _RunDos("echo upload from twitter image : "& $imgurl &" >> " & $logfile)

			   ;MsgBox(0,"image exists", $imgurls)

			   $picVisPath[$si-1] = "img"& $si &"/" & _DateDiff( 's',"1970/01/01 00:00:00",_NowCalc()) & ".jpg"

			   ;Local $cmdDown = "python down.py " & $picSavePath & " " & $imgurls
			   ;_RunDos($cmdDown)




			   Local $oImg = _IECreate($imgurl)
			   ; fullscreen mode in browser
			   WinSetState(_IEPropertyGet ($oImg,"hwnd"),"",@SW_MAXIMIZE)
			   _IEAction($oImg,"visible")
			   MouseClick("right",40,160,1)
			   Sleep(500)
			   Send("C")

			   Sleep(500)
			   MouseClick("right",40,160,1)
			   Sleep(500)
			   Send("S")
			   Sleep(500)
			   Send(@WorkingDir & "\" & $picSavePath)
			   Sleep(500)
			   Send("{Enter}")
			   Sleep(500)
			   Send("!Y")
			   Sleep(500)



			   Local $cmdPutQiniu = "putfile "& $picVisPath[$si-1] &" " & $picSavePath
			   _RunDos($cmdPutQiniu)



			   WinActivate($whichgroup)
			   Send("^{Enter}")
			   Send("^v")
			   Sleep(500)
			   _IEQuit($oImg)
			Next

		 EndIf


		 ; ȷ�Ϸ���qq��Ϣ
		 Send("{Enter}")

		 Sleep(1000)


		 ;MsgBox(0,"win active sina ", $actsn & "url:" & $text)

		 ; -------------------------------------------------- ͬʱ����΢��
		 ;Local $sinaPostUrl = $sinaPost & "?txt=" & $texten
		 ;$sinaPostUrl &= "&img=" & $picVisPre & $picVisPath[0]
		 ;_IEAction ($oSina, "visible")
		 ;_IENavigate($oSina, $sinaPostUrl)


		 If $imgurls Then
			PostWeiboWindowMode($texten, $picVisPre & $picVisPath[0])
		 Else
			PostWeiboWindowMode($texten, "")
		 EndIf


		 Sleep(1000)

		 If $imgurls Then
			For $si=1 To $imgsplits[0]
			   Local $cmdPutQiniu = "delfile "& $picVisPath[$si-1]
			   _RunDos($cmdPutQiniu)
			Next
		 EndIf



		 ; ��С����ش���
		 WinSetState(_IEPropertyGet ($oSina,"hwnd"),"",@SW_MINIMIZE)

		 $oldTid = $tid
		 _RunDos("echo "& $oldTid &" > " & $oldtidfile)
	  Else
		 ;nothing should be done
	  EndIf

	  ; sleep  5 secs after new tweets bar is clicked
	  Sleep(5000)

	  ; ÿ�� 30 ���ӹر�һ�������ץȡҳ�洰��
	  If _DateDiff( 's',$timestart,$timenow) > 1800  Then
		 ; refresh page once in 1 hour
		 ;_IEAction($oIE, "refresh")

		 _IEQuit($oIE)
		 $oIE = _IECreate($pageurl)
		 $timestart = $timenow
		 $tick = 0
	  EndIf
   WEnd
EndFunc


Func PostWeiboWindowMode($texten, $picurl)
   ; -------------------------------------------------- ͬʱ����΢��
   ;_IEAction ($oSina, "visible")
   ;_IENavigate($oSina, $sinaPostUrl)

   Local $urlSinaShare = "http://service.weibo.com/share/share.php?title="& $texten &"&pic=" & $picurl
   Local $oSinaShare = _IECreate($urlSinaShare)
   Sleep(1000)
   js($oSinaShare,"document.getElementById('shareIt').click();")



	;_RunDos("echo "& $imgurls &" >> " & $logfile)

   Local $wtit = 0
   While $wtit < 30
	  Sleep(1000)
	  ; �������ɹ����˳�ѭ��
	  If StringInStr(_IEPropertyGet($oSinaShare,"locationurl"), "share/success.php") > -1 Then
		 ExitLoop
	  EndIf
	  $wtit += 1
   WEnd

   ; �ص������ĶԻ���
   Send("!Y")
	_IEQuit($oSinaShare)
   ; -------------------------------------------------- ����΢������
EndFunc


Func GetTidFrom($oIE, $num)
   return js($oIE,"$('.stream-items .stream-item').eq(" & $num & ").attr('data-item-id') || ''")
EndFunc


Func ReadFileValue($fileAddr)
   ; read a file
   Local $file = FileOpen($fileAddr, 0)
   Local $ret = ""

   ; ����ļ��Ƿ�������
   If $file = -1 Then
	   ; create this File with empty content
	   _RunDos("echo a 2> " & $oldtidfile)
   Else
	  ; ÿ�ζ�ȡ1���ַ�ֱ���ļ���β��EOF��End-Of-File�� Ϊֹ
	  While 1
		 Local $line = FileReadLine($file)
		 If @error = -1 Then ExitLoop
		 ;MsgBox(0, "�������ı���", $line)
		 $ret = StringReplace($line," ","")
		 ExitLoop
	  Wend
   EndIf
   FileClose($file)

   Return $ret
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

