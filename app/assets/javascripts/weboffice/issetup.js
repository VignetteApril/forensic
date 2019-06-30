
document.write('<script language=javascript>var WebOfficeSetup=0;</script>');
document.write('<script language=javascript src="http://127.0.0.1:60106"></script>');
function WebOfficeInstall()
{ 
	var issetup=true;//默认值设置为WebOffice控件已安装，用于兼容旧版本的WebOffice设置
	if(WebOfficeSetup==0)
	{
		if(confirm('系统检测到此机还未安装WebOffice组件！如果确实没装过，请点击下载安装!，如果已安装过，请在本对话框中选择取消按钮以继续！'))
		{
			issetup = false;
			location.href=strRoot + "src/WebOffice.rar";
			//location.href="http://www.officectrl.com/weboffice/WebOffice.rar";
		}
	}
	return issetup;	 
}