#обть
On Error Resume Next  
Dim iRemote,iLocal  
iLocal = LCase(WScript.Arguments(1))  
iRemote = LCase(WScript.Arguments(0))  
Set xPost = createObject("Microsoft.XMLHTTP") 
xPost.Open "GET",iRemote,0 
xPost.Send() 
Set sGet = createObject("ADODB.Stream") 
sGet.Mode = 3 
sGet.Type = 1 
sGet.Open() 
sGet.Write(xPost.responseBody) 
sGet.SaveToFile iLocal,2  