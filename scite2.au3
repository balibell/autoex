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
Dim $pagetitle
Dim $oldTid
Dim $tid
Dim $num = 0
Dim $tick = 0
Dim $firstRun = True




;For $si=1 To $sss[0]
;   MsgBox(0, "Error", "[]:" & $sss[$si])
;Next



If Not WinActivate($whichgroup)  Then
   MsgBox(0, "Error", "���ȴ�Ŀ�����촰�ڡ�"& $whichgroup &"������ִ�б�����")
   Exit
EndIf




Dim $oSina
Dim $oIE = _IECreate($pageurl)
;js($oIE,FileRead("jquery-2.0.2.js"))







; get page title
$pagetitle = js($oIE,"(document.title)")
;MsgBox(0, "title", $pagetitle)

; read a file
Dim $file = FileOpen($oldtidfile, 0)

; ����ļ��Ƿ�������
If $file = -1 Then
    ; create this File
	_RunDos("echo 0 > " & $oldtidfile)
Else
   ; ÿ�ζ�ȡ1���ַ�ֱ���ļ���β��EOF��End-Of-File�� Ϊֹ
   While 1
	  Dim $line = FileReadLine($file)
	  If @error = -1 Then ExitLoop
	  ;MsgBox(0, "�������ı���", $line)
	  $oldTid = StringReplace($line," ","")
	  ExitLoop
   Wend
EndIf
FileClose($file)


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

   $tid = js($oIE,"($('.stream-items .stream-item').eq(" & $num & ").attr('data-item-id'))")
   MsgBox(0, $tick & "whole thing",$tid)

   If $oldTid <> $tid And $tid Then
   ;If True Then
	  WinActivate($pagetitle)
	  Sleep(2000)




	  Local $texten = js($oIE,"encodeURIComponent($('.stream-items .stream-item').eq(" & $num & ").find('.tweet-text').text().replace(/ *pic\.twitter\.com.*/,''))")
	  Local $imgurls = js($oIE,"$('.stream-items .stream-item').eq(" & $num & ").find('.cards-media-container').attr('expimgs','').find('[data-resolved-url-large]').each(function(i,e){var $t=$(e),$c=$t.closest('.cards-media-container'),imgs=$c.attr('expimgs') || '';$c.attr('expimgs', imgs+ (i == 0 ? '' : ',') + $t.attr('data-resolved-url-large'))}).closest('.cards-media-container').attr('expimgs') || ''")
	  Local $imgurl = StringSplit($imgurls,",")[1]

	  ;Local $text = _UTFToString($texten)
	  Local $text = js($oIE,"decodeURIComponent('"& $texten &"')")

	  _RunDos("echo "& StringRegExpReplace($text,"[&<>|]","") &" >> " & $logfile)

	  Local $picSavePath = "img\tmp0.jpg"
	  Local $picVisPath
	  Local $picVisUrl

	  ;MsgBox(0,"whole thing",$tid&$text)
	  If $imgurls Then
		 _RunDos("echo "& $imgurls &" >> " & $logfile)

		 ;MsgBox(0,"image exists", $imgurls)

		 $picVisPath = "img/" & _DateDiff( 's',"1970/01/01 00:00:00",_NowCalc()) & ".jpg"
		 $picVisUrl = "http://7u2o9e.com1.z0.glb.clouddn.com/" & $picVisPath
		 ;Local $cmdDown = "python down.py " & $picSavePath & " " & $imgurls
		 ;_RunDos($cmdDown)


		 ;MsgBox(0,"reimg", $picVisUrl)

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

		 Local $cmdPutQiniu = "putfile "& $picVisPath &" " & $picSavePath
		 _RunDos($cmdPutQiniu)
	  EndIf


	  WinActivate($whichgroup)
	  Send($text,1)


	  ; ����΢��������ƴװ
	  ;Local $texten = js($oSina,"(encodeURIComponent('\"\'sf'))")
	  Local $sinaPostUrl = $sinaPost & "?txt=" & $texten

	  If $imgurls Then
		 $sinaPostUrl &= "&img=" & $picVisUrl


		 ;MsgBox(0,"image ", $imgurls)
		 Send("^{Enter}")
		 Send("^v")
		 Sleep(500)
		 _IEAction($oImg,"quit")
	  EndIf

	  Send("{Enter}")

	  Sleep(1000)


	  ;MsgBox(0,"win active sina ", $actsn & "url:" & $text)

	  ; -------------------------------------------------- ͬʱ����΢��
	  ;_IEAction ($oSina, "visible")
	  ;_IENavigate($oSina, $sinaPostUrl)

	  Local $urlSinaShare = "http://service.weibo.com/share/share.php?title="& $texten &"&pic=" & $picVisUrl
	  Local $oSinaShare = _IECreate($urlSinaShare)
	  Sleep(500)
	  js($oSinaShare,"document.getElementById('shareIt').click();")

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
	   _IEAction($oSinaShare, "quit")
	  ; -------------------------------------------------- ����΢������



	  Sleep(1000)
	  Local $cmdPutQiniu = "delfile "& $picVisPath
	  _RunDos($cmdPutQiniu)


	  ; ��С����ش���
	  WinSetState(_IEPropertyGet ($oIE,"hwnd"),"",@SW_MINIMIZE)
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

	  _IEAction($oIE, "quit")
	  $oIE = _IECreate($pageurl)
	  $timestart = $timenow
	  $tick = 0
   EndIf
WEnd


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

