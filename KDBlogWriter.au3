#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=1.0.0.3
#AutoIt3Wrapper_Res_Language=1028
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs

Changelog:
2009/08/18 1.0.0.3 by tsaikd@gmail.com
Show appver in app title

2009/08/16 1.0.0.2 by tsaikd@gmail.com
Fix bug: when only one article will crash at saving, deleting article
Add support <quote>

2008/12/28 1.0.0.1 by tsaikd@gmail.com
First Release

#ce

#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WinAPI.au3>
#Include <GuiEdit.au3>
#include <Date.au3>
#include <Array.au3>
#include <String.au3>
#Include <GuiComboBox.au3>
#include <GuiListView.au3>

; Variable Definition
Global Const $appname = "KDBlogWriter"
Global Const $appver = "1.0.0.2"
Global Const $appdate = "2009/08/16"
Global Const $author = "tsaikd@gmail.com"

Global Const $app = $appname&" "&$appver
Global Const $appini = @WorkingDir&"\"&$appname&".ini"

Global $appwidth = 1000
Global $appheight = 700
Global $appgui

Global $edtTitle
Global $cboTag1
Global $cboTag2
Global $cboTag3
Global $edtBlogBody
Global $edtAddPicDate
Global $lstArticle

Global $hFirstArticle = -1
Global $hLastArticle = -1

Global $sTitle

Func Main()
	$hDesktop = _WinAPI_GetDesktopWindow()
	$appwidth = _WinAPI_GetClientWidth($hDesktop) * 0.8
	$appheight = _WinAPI_GetClientHeight($hDesktop) * 0.9 - 50

	$appgui = GUICreate($app, $appwidth, $appheight)
	AutoItWinSetTitle($appname)

	$iWinBH = 5
	$iCtrlGap = 10
	$iCtrlH = 30
	$iLblH = 14
	$iLblO = ($iCtrlH-$iLblH)/2
	$iBtnW = 110
	$iBtnH = 25
	$iEdtW = 180
	$iEdtH = 19
	$iCboW = 120
	$iCboH = 20

	$sTagListDef = "生活|資訊|科技|KUSO|資安|新聞|思考|備忘|主機|Windows|Linux|佳句|電影|遊戲|程式/Qt|KDProject|KDProject/KDGallery|KDProject/KDBlog"
	$sTagListFull = IniRead($appini, "Global", "sTagListFull", $sTagListDef)
	$aTags = StringSplit($sTagListFull, "|")
	$sDefTag = $aTags[1]
	$sTagList = _ArrayToString($aTags, "|", 2)

	$edtTitle = GUICtrlCreateInput("", $iCtrlGap, $iCtrlGap, $iEdtW, $iEdtH)
;	$cboTag1 = GUICtrlCreateCombo($sDefTag, $iCtrlGap+($iCtrlGap+$iEdtW)*1, $iCtrlGap, $iCboW, $iCboH)
;	GUICtrlSetData(-1, $sTagList, $sDefTag) 
	$cboTag1 = GUICtrlCreateCombo(" ", $iCtrlGap+($iCtrlGap+$iEdtW)*1+($iCtrlGap+$iCboW)*0, $iCtrlGap, $iCboW, $iCboH)
	GUICtrlSetData(-1, $sDefTag&"|"&$sTagList) 
	$cboTag2 = GUICtrlCreateCombo(" ", $iCtrlGap+($iCtrlGap+$iEdtW)*1+($iCtrlGap+$iCboW)*1, $iCtrlGap, $iCboW, $iCboH)
	GUICtrlSetData(-1, $sDefTag&"|"&$sTagList) 
	$cboTag3 = GUICtrlCreateCombo(" ", $iCtrlGap+($iCtrlGap+$iEdtW)*1+($iCtrlGap+$iCboW)*2, $iCtrlGap, $iCboW, $iCboH)
	GUICtrlSetData(-1, $sDefTag&"|"&$sTagList) 
	$edtBlogBody = GUICtrlCreateEdit("", $iCtrlGap, $iCtrlGap+$iEdtH+$iCtrlGap, $appwidth-$iCtrlGap*2-$iCtrlGap-$iEdtW, $appheight-$iCtrlGap*2-$iCtrlGap-$iCboH-$iCtrlGap-$iBtnH)
	GUICtrlSetFont(-1, 15)
	$lstArticle = GUICtrlCreateListView("                  "&_("Title")&"                  ", $appwidth-$iCtrlGap*1-$iEdtW, $iCtrlGap, $iEdtW, $appheight-$iCtrlGap*2-$iCtrlGap-$iBtnH)
	$edtAddPicDate = GUICtrlCreateInput(_NowCalcDate() , $iCtrlGap, $appheight-$iCtrlH-$iWinBH+2, 65, $iEdtH)
	$btnAddPic = GUICtrlCreateButton(_("Add&Pic"), $iCtrlGap+75+($iCtrlGap+$iBtnW)*0, $appheight-$iCtrlH-$iWinBH, $iBtnW, $iBtnH)
	$btnAddQuote = GUICtrlCreateButton(_("Add&Quote"), $iCtrlGap+75+($iCtrlGap+$iBtnW)*1, $appheight-$iCtrlH-$iWinBH, $iBtnW, $iBtnH)
	$btnClip = GUICtrlCreateButton(_("&ClipBoard"), $iCtrlGap+75+($iCtrlGap+$iBtnW)*2, $appheight-$iCtrlH-$iWinBH, $iBtnW, $iBtnH)
	$btnDelArticle = GUICtrlCreateButton(_("&Delete"), $appwidth-$iCtrlGap-$iBtnW, $appheight-$iCtrlH-$iWinBH, $iBtnW, $iBtnH)

	$sArticleList = IniRead($appini, "Global", "sArticleList", "")
	$aArticle = StringSplit($sArticleList, "|")
	If $aArticle[0] > 0 Then LoadArticle($aArticle[1])
	$hFirstArticle = -1
	$hLastArticle = -1
	For $i=1 To $aArticle[0]
		$buf = GUICtrlCreateListViewItem($aArticle[$i], $lstArticle)
		If $hFirstArticle == -1 Then $hFirstArticle = $buf
		If $hLastArticle < $buf Then $hLastArticle = $buf
	Next

	$btnMsgExit = GUICtrlCreateButton("", 0, 0)
	GUICtrlSetState(-1, $GUI_HIDE)
	$btnMsgSelectAll = GUICtrlCreateButton("", 0, 0)
	GUICtrlSetState(-1, $GUI_HIDE)

	Dim $aAccelKeys[2][2] = [ _
		["{ESC}", $btnMsgExit] , _
		["^a", $btnMsgSelectAll] _
	]

	GUISetAccelerators($aAccelKeys)
	GUISetState()

	While 1
		$msg = GUIGetMsg()

		Select
		Case $msg == $GUI_EVENT_CLOSE Or $msg == $btnMsgExit
			ExitLoop
		Case $msg == $btnMsgSelectAll
			btnMsgSelectAll()
		Case $msg == $btnClip
			btnClip()
		Case $msg == $btnAddPic
			btnAddPic()
		Case $msg == $btnAddQuote
			btnAddQuote()
		Case $msg == $btnDelArticle
			btnDelArticle()
		Case $msg >= $hFirstArticle And $msg <= $hLastArticle
			lstArticleSelect()
		EndSelect
	WEnd

	SaveArticle()

	$sTagListFull = "|"&$sTagListFull&"|"
	$buf = StringTrim(GUICtrlRead($cboTag1))
	If $buf <> "" And Not StringInStr($sTagListFull, "|"&$buf&"|") Then
		$sTagListFull = $sTagListFull&$buf&"|"
	EndIf
	$buf = StringTrim(GUICtrlRead($cboTag2))
	If $buf <> "" And Not StringInStr($sTagListFull, "|"&$buf&"|") Then
		$sTagListFull = $sTagListFull&$buf&"|"
	EndIf
	$buf = StringTrim(GUICtrlRead($cboTag3))
	If $buf <> "" And Not StringInStr($sTagListFull, "|"&$buf&"|") Then
		$sTagListFull = $sTagListFull&$buf&"|"
	EndIf
	$sTagListFull = StringTrimLeft($sTagListFull, 1)
	$sTagListFull = StringTrimRight($sTagListFull, 1)
	IniWriteSmart("Global", "sTagListFull", $sTagListFull, $sTagListDef)

	GUIDelete()
EndFunc

Func StringTrim($s)
	If StringLen($s) < 1 Then Return ""
	While StringRegExp(StringLeft($s, 1), "\s")
		$s = StringTrimLeft($s, 1)
	WEnd
	While StringRegExp(StringRight($s, 1), "\s")
		$s = StringTrimRight($s, 1)
	WEnd
	Return $s
EndFunc

Func IniWriteSmart($section, $key, $value, $defval = "")
	If $value == $defval Then
		IniDelete($appini, $section, $key)
	Else
		IniWrite($appini, $section, $key, $value)
	EndIf
EndFunc

Func IniEscape($s)
	$s = StringReplace($s, @CRLF, "\n")
	Return $s
EndFunc

Func IniDeEscape($s)
	$s = StringReplace($s, "\n", @CRLF)
	Return $s
EndFunc

Func LoadArticle($sTitle)
	If $sTitle == "" Then Return
	GUICtrlSetData($edtTitle, $sTitle)
	GUICtrlSetData($edtBlogBody, IniDeEscape(IniRead($appini, $sTitle, "sBlogBody", "")))

	$i = _GUICtrlComboBox_FindStringExact($cboTag1, IniRead($appini, $sTitle, "sTag1", " "))
	If $i < 0 Then $i = 0
	_GUICtrlComboBox_SetCurSel($cboTag1, $i)

	$i = _GUICtrlComboBox_FindStringExact($cboTag2, IniRead($appini, $sTitle, "sTag2", " "))
	If $i < 0 Then $i = 0
	_GUICtrlComboBox_SetCurSel($cboTag2, $i)

	$i = _GUICtrlComboBox_FindStringExact($cboTag3, IniRead($appini, $sTitle, "sTag3", " "))
	If $i < 0 Then $i = 0
	_GUICtrlComboBox_SetCurSel($cboTag3, $i)
EndFunc

Func SaveArticle()
	$sTitle = StringTrim(GUICtrlRead($edtTitle))
	If $sTitle == "" Then Return
	$sArticleList = IniRead($appini, "Global", "sArticleList", "")
	$aArticle = StringSplit($sArticleList, "|")
	_ArrayDelete($aArticle, 0)
	If UBound($aArticle) > 1 Then
		$i = _ArraySearch($aArticle, $sTitle)
		If $i >= 0 Then _ArrayDelete($aArticle, $i)
		_ArrayInsert($aArticle, 0, $sTitle)
		$i = UBound($aArticle)-1
		If $aArticle[$i] == "" Then _ArrayPop($aArticle)
	Else
		$aArticle[0] = $sTitle
	EndIf
	$sArticleList = _ArrayToString($aArticle)
	IniWriteSmart("Global", "sArticleList", $sArticleList, "")
	IniWriteSmart($sTitle, "sBlogBody", IniEscape(StringTrim(GUICtrlRead($edtBlogBody))), "")
	IniWriteSmart($sTitle, "sTag1", StringTrim(GUICtrlRead($cboTag1)), "")
	IniWriteSmart($sTitle, "sTag2", StringTrim(GUICtrlRead($cboTag2)), "")
	IniWriteSmart($sTitle, "sTag3", StringTrim(GUICtrlRead($cboTag3)), "")
EndFunc

Func btnMsgSelectAll()
	GUICtrlSetState($edtBlogBody, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($edtBlogBody, 0, -1)
EndFunc

Func btnClip()
	$data = ""
	$data = $data&'<?xml version="1.0" encoding="utf-8" ?>'&@CRLF
	$data = $data&'<article>'&@CRLF

	$data = $data&'<title>'&GUICtrlRead($edtTitle)&'</title>'&@CRLF

	$buf = StringTrim(GUICtrlRead($cboTag1))
	If StringLen($buf) > 0 Then $data = $data&'<tag>'&$buf&'</tag>'&@CRLF
	$buf = StringTrim(GUICtrlRead($cboTag2))
	If StringLen($buf) > 0 Then $data = $data&'<tag>'&$buf&'</tag>'&@CRLF
	$buf = StringTrim(GUICtrlRead($cboTag3))
	If StringLen($buf) > 0 Then $data = $data&'<tag>'&$buf&'</tag>'&@CRLF

	$buf = GUICtrlRead($edtBlogBody)
	$buf = StringTrim($buf)
	If StringRegExp($buf, "<kdgallery.*?>") Then
		$data = $data&'<macro name="kdgallery" />'&@CRLF
		$buf = StringRegExpReplace($buf, "<(kdgallery.*?)>", "\\<\1\\>")
	EndIf
	If StringRegExp($buf, "<quote.*?>") Then
		$data = $data&'<macro name="quote" />'&@CRLF
		$buf = StringRegExpReplace($buf, "<(quote.*?)>", "\\<\1\\>")
		$buf = StringRegExpReplace($buf, "<(/quote)>", "\\<\1\\>")
	EndIf

	$buf = StringReplace($buf, "<", "&lt;")
	$buf = StringReplace($buf, ">", "&gt;")
	$buf = StringReplace($buf, "\&lt;", "<")
	$buf = StringReplace($buf, "\&gt;", ">")
	$data = $data&'<contents>'&@CRLF
	$data = $data&$buf&@CRLF
	$data = $data&'</contents>'&@CRLF
	$data = $data&'</article>'
	ClipPut($data)
EndFunc

Func btnAddPic()
	Local $data = '<kdgallery src="data/KDBlog/'&GUICtrlRead($edtAddPicDate)&'/.jpg" />'
	Local $aPos = _GUICtrlEdit_GetSel($edtBlogBody)
	Local $pos = $aPos[0]
	_GUICtrlEdit_InsertText($edtBlogBody, $data, $pos)

	$pos = $pos + 39
	GUICtrlSetState($edtBlogBody, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($edtBlogBody, $pos, $pos)
EndFunc

Func btnAddQuote()
	Local $data = '<quote header="">' & @CRLF & @CRLF & '</quote>'
	Local $aPos = _GUICtrlEdit_GetSel($edtBlogBody)
	Local $pos = $aPos[0]
	_GUICtrlEdit_InsertText($edtBlogBody, $data, $pos)

	$pos = $pos + 19
	GUICtrlSetState($edtBlogBody, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($edtBlogBody, $pos, $pos)
EndFunc

Func btnDelArticle()
	$sTitle = GUICtrlRead(GUICtrlRead($lstArticle))
	$sTitle = StringTrimRight($sTitle, 1)
	If $sTitle == "" Then Return
	$sArticleList = IniRead($appini, "Global", "sArticleList", "")
	$aArticle = StringSplit($sArticleList, "|")
	_ArrayDelete($aArticle, 0)
	$i = _ArraySearch($aArticle, $sTitle)
	If $i >= 0 Then _ArrayDelete($aArticle, $i)
	$i = UBound($aArticle)-1
	If $i >= 0 And $aArticle[$i] == "" Then _ArrayPop($aArticle)
	$sArticleList = _ArrayToString($aArticle)
	IniWriteSmart("Global", "sArticleList", $sArticleList, "")
	IniDelete($appini, $sTitle)
	_GUICtrlListView_DeleteItemsSelected($lstArticle)
	GUICtrlSetData($edtTitle, "")
EndFunc

Func lstArticleSelect()
	SaveArticle()
	$sTitle = GUICtrlRead(GUICtrlRead($lstArticle))
	$sTitle = StringTrimRight($sTitle, 1)
	LoadArticle($sTitle)
EndFunc

Func _($s)
	Switch($s)
	Case "Title"
		Return "標題"
	Case "&ClipBoard"
		Return "複製到剪貼簿(&C)"
	Case "Add&Pic"
		Return "插入圖片(&P)"
	Case "Add&Quote"
		Return "插入引言(&Q)"
	Case "&Delete"
		Return "刪除(&D)"
	EndSwitch
	Return $s
EndFunc

Main()
