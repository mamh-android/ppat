var xmlDoc;
var powerCase = new Array();
var powerComponent = new Array();
var performanceCase = new Array();
var powerDevice = new Array();
var deviceComponent = new Array();
function ppat_load(){
	var strURL = "http://10.38.32.178:3000/scenarios";
			$.ajax({
			  type: "GET",
			  url: strURL,
				timeout:3000,
				dataType:'html',
			  success: function(msg){
					domParser = new DOMParser();
					xmlDoc = domParser.parseFromString(msg, 'text/xml');
					ppat_parsePowerNode();
					ppat_parsePerformanceNode();
					ppat_parseDeviceNode();
					generateUI();
			  }
			});
}

function ppat_parseDeviceNode(){
	var nodes = xmlDoc.getElementsByTagName("Device");
	for(i = 0; i < nodes.length; i++){
		var str = "{";
		str += "\"name\":\"" + nodes[i].getElementsByTagName("Name")[0].firstChild.nodeValue + "\",";
		var testcases = nodes[i].getElementsByTagName("CaseName");
		var cases = new Array();
		for(j = 0; j < testcases.length; j++){
				cases.push(testcases[j].firstChild.nodeValue);
				powerComponent.push(testcases[j].getAttribute("Component"));
				deviceComponent.push(testcases[j].getAttribute("Component"));
		}		
		str += "\"TestCase\":\"" + cases + "\"";
		str += "}";
		powerDevice.push(eval('(' + str + ')'));
	}
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

function generateUI(){

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
			label.innerHTML="<b>Power Consumption Test:</b>";
		
			submit.parentNode.appendChild(label, submit);
			ppat_addBr(submit);
			for(var i = 0; i < powerCase.length; i++){
				ppat_addCheckbox(submit, "power", powerCase[i], powerComponent[i]);
			}	
			ppat_addhr(submit);
			
			label = document.createElement("label");
			label.id="powerDevice";
			label.name="powerdevice";
			label.innerHTML="<b>Choose Camera/WiFi/BT Test Cases:</b>";
		
			submit.parentNode.appendChild(label, submit);
			ppat_addBr(submit);
			for(var j = 0; j < powerDevice.length; j++){

					var radio = document.createElement("input");
					radio.id = powerDevice[j].name;
					radio.type = "radio";
					radio.name = "device";
					radio.onclick=(function(n){return function(){ ppat_addDeviceCase(powerDevice[n].TestCase, div);}})(j);
					radio.value = powerDevice[j].name;		
					submit.parentNode.appendChild(radio, submit);	
					submit.parentNode.appendChild(document.createTextNode(powerDevice[j].name), submit);	
			}
			var div = document.createElement("div");
			div.id="power_device";		
			submit.parentNode.appendChild(div, submit);
			ppat_addhr(submit);

			
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
			ppat_addhr(submit);

			var label = document.createElement("label");
			label.id="power";
			label.name="power";
			label.innerHTML="<b>UI Performance Test:</b>";
		
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
			ppat_addhr(submit);
			label = document.createElement("label");
			label.id="power";
			label.name="power";
			label.innerHTML="<b>Please input some special commands before run each case:</b>";
		
			submit.parentNode.appendChild(label, submit);
			ppat_addBr(submit);
			var textarea = document.createElement("textarea");
			textarea.cols = 60;
			textarea.rows = 10;
			textarea.id = "ppat_testarea";
		
			submit.parentNode.appendChild(textarea, submit);
		
			ppat_addBr(submit);
			ppat_addhr(submit);
/*
//remove the "add ppat to textfield button"
			button = document.createElement("input");
			button.type="button";
			button.name="Add to PPAT Test TextField";
			button.onclick=function(){ ppat_appendToText();};
			button.value="Add to PPAT Test TextField";
			submit.parentNode.appendChild(button, submit);
*/
			$("#Device1").checked="Device1";
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

function ppat_addhr(before){
	var hr = document.createElement("hr");
	before.parentNode.appendChild(hr, before);
}

function ppat_addDeviceCase(device, before){
		var testcases = device.split(",");
		var submit = document.getElementById("power_device");	
		$("#power_device").html("");
		for(i = 0; i < testcases.length; i++){
			//ppat_addCheckbox(submit, "device", testcases[i], testcases[i]);
			var power = document.createElement("input"); 
			power.type="checkbox";
			power.value=deviceComponent[i];
			power.name="power";
			submit.appendChild(power, submit);
			submit.appendChild(document.createTextNode(testcases[i]), submit);
		}
		
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

function ppat_triggerValidate(thisform)
{
	with (thisform)
	{
		if (ppat_validateRequired(property4value, "please input the Reason for Build") == false)
		{
			property4value.focus();
			return false;
		}
		if (ppat_validateRequired(property1value, "please input the Image Path") == false)
		{
			property1value.focus();
			return false;
		}
		if (ppat_validateRequired(property6value, "please select the device") == false)
		{
			property6value.focus();
			return false;
		}
		if (ppat_validateRequired(property7value, "please select the blf") == false)
		{
			property7value.focus();
			return false;
		}
        if (ppat_validateRequired(property3value, "please select power or performance test cases") == false)
        {
            property3value.focus();
            return false;
        }
//load append ppat.xml to Text after validate
	ppat_appendToText();
	}
}

function ppat_validateRequired(field, alerttxt)
{
        with (field)
        {
                if (value==null||value=="")
                {
                alert(alerttxt);
                focus();
                return false;
        }
                for (i = 0; i < value.length; i++)
                {
                        c = value.substr(i, 1);
                        ts = escape(c);
                        if(ts.substring(0,2) == "%u")
                        {
                                alert("Chinese characters is not allowed!");
                                value = "";
                                return false;
                        }
                }
        }
}
