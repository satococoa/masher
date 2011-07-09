/*--------------------------------------------------------------------------*
 *  
 *  wordBreak JavaScript Library for Opera & Firefox
 *  
 *  MIT-style license. 
 *  
 *  2008 Kazuma Nishihata 
 *  http://www.to-r.net
 *  
 *--------------------------------------------------------------------------*/


new function(){
	if(window.opera || navigator.userAgent.indexOf("Firefox") != -1){
		var wordBreak = function() {
			var wordBreakClass = "wordBreak";
			var table = document.getElementsByTagName("table");
			for(var i=0,len=table.length ; i<len ; i++){
				var tbClass = table[i].className.split(/\s+/);
				for (var j = 0; j < tbClass.length; j++) {
					if (tbClass[j] == wordBreakClass) {
						recursiveParse(table[i])
					}
				}
			}
		}
		var recursiveParse = function(pNode) {
			var childs = pNode.childNodes;
			for (var i = 0; i < childs.length; i++) {
				var cNode = childs[i];
				if (childs[i].nodeType == 1) {
					recursiveParse(childs[i]);
				}else if(cNode.nodeType == 3) {
					if(cNode.nodeValue.match("[^\n ]")){
						var plTxt = cNode.nodeValue.replace(/\t/g,"")
						var spTxt = plTxt.split("");
						spTxt = spTxt.join(String.fromCharCode(8203));
						var chNode = document.createTextNode(spTxt);
						cNode.parentNode.replaceChild(chNode,cNode)
					}
				}
			}
		}

	}else{
		var wordBreak = function() {
			if( document.styleSheets[0].addRule ){
				document.styleSheets[0].addRule(".wordBreak","word-break:break-all");
			}else if( document.styleSheets[0].insertRule ){
				document.styleSheets[0].insertRule(".wordBreak{word-break:break-all}", document.styleSheets[0].cssRules.length );
			}else{
				return false;
			}
		}
	}
	var addEvent = function(elm,listener,fn){
		try{
			elm.addEventListener(listener,fn,false);
		}catch(e){
			elm.attachEvent("on"+listener,fn);
		}
	}
	addEvent(window,"load",wordBreak);
}