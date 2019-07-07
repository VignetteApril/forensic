
///////////////////////////////////////////////////////////////////
/////检测浏览器版本
function getBrowser(){	
    var Sys = {};
    var ua = navigator.userAgent.toLowerCase();
    var s;
	var ver;
    (s = ua.match(/edge\/([\d.]+)/)) ? Sys.edge = s[1] :
    (s = ua.match(/rv:([\d.]+)\) like gecko/)) ? Sys.ie = s[1] :
    (s = ua.match(/msie ([\d.]+)/)) ? Sys.ie = s[1] :
    (s = ua.match(/firefox\/([\d.]+)/)) ? Sys.firefox = s[1] :
    (s = ua.match(/chrome\/([\d.]+)/)) ? Sys.chrome = s[1] :
    (s = ua.match(/opera.([\d.]+)/)) ? Sys.opera = s[1] :
    (s = ua.match(/version\/([\d.]+).*safari/)) ? Sys.safari = s[1] : 0;
	if (Sys.edge) return 1;
	if (Sys.ie) return 0; 
    if (Sys.firefox) return 1;
    if (Sys.chrome){ ver = Sys.chrome;ver.toLowerCase();var arr = ver.split('.');if(parseInt(arr[0])>43){return 1;}else{return 0;}}
    if (Sys.opera) return 1;
    if (Sys.safari) return 1;
	return 1;
}

/////打开含控件的网页
function ShowPage(path)
{ 
	var pre = "WebOffice://|Officectrl|";//智能窗打开的固定参数
	var v=getBrowser();	
	if(v==1){//当浏览器返回值为1时定义为使用智能窗方式打开网址
		strUrl = pre + path;
		alert(strUrl)
		window.open(strUrl,'_self');
	}
	else
	{ //当浏览器返回值1以外的数据时采用传统方式打开网址
		strUrl = pre + path;
		window.open(strUrl,'_blank');
	}
}
