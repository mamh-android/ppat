var url="ppat_config.xml"
var xmlDoc;
var powerCase = new Array();
var powerComponent = new Array();
var performanceCase = new Array();
function readXML(){
	var strURL = "http://10.38.32.178:3000/scenarios";

			$.ajax({
			  type: "GET",
			  url: strURL,
			  success: function(msg){
					domParser = new DOMParser();
					xmlDoc = domParser.parseFromString(msg, 'text/xml');
					ppat_parsePowerNode();
					ppat_parsePerformanceNode();
			  }
			});
}

function ppat_parsePowerNode(){
	var nodes = xmlDoc.getElementsByTagName("Power");

	for(i = 0; i < nodes.length; i++){
		caseName = nodes[i].getElementsByTagName("CaseName")[0].firstChild.nodeValue;
		component = nodes[i].getElementsByTagName("Component")[0].firstChild.nodeValue;
		powerCase.push(caseName);
		powerComponent.push(component);
	}		
}

function ppat_parsePerformanceNode(){
	var nodes = xmlDoc.getElementsByTagName("Performance");

	for(i = 0; i < nodes.length; i++){
		caseName = nodes[i].getElementsByTagName("CaseName")[0].firstChild.nodeValue;
		performanceCase.push(caseName);
	}		
}

function ppat_load(){
		readXML();

		var check = document.getElementsByName("property2value")[0];
		if(check.checked){
			if(! document.getElementById("power_test")){
		
			var p_ele = document.getElementsByTagName("p");
			var submitbtn = p_ele[p_ele.length - 2];
		
			var div = document.createElement("div");
			div.id="power_test";		
			submitbtn.appendChild(div, submitbtn);

			var submit = document.getElementById("power_test");

			var label = document.createElement("label");
			label.id="power";
			label.name="power";
			label.innerHTML="Power Consumption Test:";
		
			submit.parentNode.appendChild(label, submit);
			ppat_addBr(submit);
			for(var i = 0; i < powerCase.length; i++){
				ppat_addCheckbox(submit, "power", powerCase[i], powerComponent[i]);
			}	
			ppat_addBr(submit);

			var button = document.createElement("input");
			button.type="button";
			button.name="Button_SelectAll";
			button.onclick= function(){ ppat_CheckboxSelectAll('power');};
			button.value="Select All";
			submit.parentNode.appendChild(button, submit);

			button = document.createElement("input");
			button.type="button";
			button.name="Button_ClearAll";
			button.onclick=function(){ ppat_CheckboxSelectClear('power');};
			button.value="Clear ALL";
			submit.parentNode.appendChild(button, submit);
			powerComponent = powerComponent.del();

			for(var i = 0; i < powerComponent.length; i++){

				var buttons = document.createElement("input");
				buttons.type="button";
				buttons.name=powerComponent[i];
				buttons.onclick=(function(n){ return function(){ppat_CheckboxSelectComponent('power', powerComponent[n]);}})(i);
				buttons.value="Choose " + powerComponent[i];
				submit.parentNode.appendChild(buttons, submit);
			}	
	
			ppat_addBr(submit);
			var label = document.createElement("label");
			label.id="power";
			label.name="power";
			label.innerHTML="UI Performance Test:";
		
			submit.parentNode.appendChild(label, submit);
			ppat_addBr(submit);
			for(var i = 0; i < performanceCase.length; i++){
				ppat_addCheckbox(submit,"performance", performanceCase[i]);
			}
			ppat_addBr(submit);

			button = document.createElement("input");
			button.type="button";
			button.name="Button_SelectAll";
			button.onclick= function(){ ppat_CheckboxSelectAll('performance');};
			button.value="Select All";
			submit.parentNode.appendChild(button, submit);

			button = document.createElement("input");
			button.type="button";
			button.name="Button_ClearAll";
			button.onclick=function(){ ppat_CheckboxSelectClear('performance');};
			button.value="Clear ALL";
			submit.parentNode.appendChild(button, submit);
			powerComponent = powerComponent.del();
	
			ppat_addBr(submit);
			label = document.createElement("label");
			label.id="power";
			label.name="power";
			label.innerHTML="Please input some special commands before run each case:";
		
			submit.parentNode.appendChild(label, submit);
			ppat_addBr(submit);
			var textarea = document.createElement("textarea");
			textarea.cols = 60;
			textarea.rows = 10;
			textarea.id = "ppat_testarea";
		
			submit.parentNode.appendChild(textarea, submit);
		
			ppat_addBr(submit);
			
			button = document.createElement("input");
			button.type="button";
			button.name="Add to PPAT Test TextField";
			button.onclick=function(){ ppat_appendToText();};
			button.value="Add to PPAT Test TextField";
			submit.parentNode.appendChild(button, submit);
			}
		}
}

function ppat_appendToText(){
			var chks = document.getElementsByTagName("input");
			var jsonStr="";
			var textfiled;
			var caseCount = 0;
       for (var i = 0; i < chks.length; i++) {
            if (chks[i].type == "checkbox" && chks[i].checked && chks[i].name != "property2value") {
								if(chks[i].nextSibling.nodeValue != "" && chks[i].nextSibling.nodeValue != null){
										caseCount += 1;
										jsonStr += "{\"Name\":\"" + chks[i].nextSibling.nodeValue + "\"},";
									}
              }
						if(chks[i].name == "property3value"){
									textfiled = chks[i];
						}
          }
			if(caseCount >= 1){
				jsonStr = "{\"TestCaseList\":[" + jsonStr.substring(0, jsonStr.length - 1) + "]";
				var text = document.getElementById("ppat_testarea").value;
				if(text != ""){
						jsonStr +=",\"inputs\":\"" + text.replace(/[\n]/ig,'&amps;') + "\"";							
				}
				jsonStr += "}"; 
				
			textfiled.value=jsonStr; 
			}else{
				alert('Please at least choose a Power or Performance test case');
			}
}

function ppat_addBr(before){
	var br = document.createElement("br");
	before.parentNode.appendChild(br, before);
}

function ppat_addCheckbox(before, name, v, component){
		var power = document.createElement("input"); 
		power.type="checkbox";
		power.value=component;
		power.name=name;
		
		before.parentNode.appendChild(power, before);
		before.parentNode.appendChild(document.createTextNode(v), before);
};

function ppat_CheckboxSelectAll(name) {  
	
    var checkbox = document.getElementsByTagName("input");
		for( var i = 0; i < checkbox.length; i++){
			if(checkbox[i].type == "checkbox" && checkbox[i].name == name){
				checkbox[i].checked = true;
			}
		}
  }  

function ppat_CheckboxSelectComponent(name, component) { 
    var checkbox = document.getElementsByTagName("input");
		for( var i = 0; i < checkbox.length; i++){
			if(checkbox[i].type == "checkbox" && checkbox[i].name == name && checkbox[i].value == component){
				checkbox[i].checked = true;
			}
		}
  } 

function ppat_CheckboxSelectClear(name) {  
    var checkbox = document.getElementsByTagName("input");
		for( var i = 0; i < checkbox.length; i++){
			if(checkbox[i].type == "checkbox" && checkbox[i].name == name){
				checkbox[i].checked = false;
			}
		}
   } 

Array.prototype.del = function() { 
	var a = {}, c = [], l = this.length; 
	for (var i = 0; i < l; i++) { 
		var b = this[i]; 
		var d = (typeof b) + b; 
		if (a[d] === undefined) { 
			c.push(b); 
			a[d] = 1; 
		} 
	} 
	return c; 
} 

