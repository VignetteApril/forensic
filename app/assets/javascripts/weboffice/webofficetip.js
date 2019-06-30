document.write('<input type=button value="关闭智能窗口" onclick="window.opener=null;window.open(\'\',\'_self\',\'\');window.close();">&nbsp;&nbsp;&nbsp;&nbsp;无法看到控件?&nbsp;<a href="http://www.officectrl.com/weboffice/weboffice.rar">下载WebOffice.rar</a>完成后重新打开本页面。如仍无法看到控件，谷歌Chrome或FireFox等所有浏览器均可使用：<a href="javascript:SmartOpen();">智能窗口链接</a>');
function SmartOpen()
{
	location.href=strSmartUrl;
}
