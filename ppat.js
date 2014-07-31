var xmlDoc;
var powerCase;
var powerCategory;
var performanceCase;
var powerDevice;
var deviceCategory;
var powerAdvancedCase;
var	platform;
var boardDevice;
var powerAdvCategory;
var device;
var testType;
var testcases="";
var countOfCmds=1;
function ppat_load(buildtype){
    var strURL = "http://10.38.32.97:3000/scenarios";
            $.ajax({
              type: "GET",
              url: strURL,
                timeout:3000,
                dataType:'html',
              success: function(msg){
                    powerCase = new Array();
                    powerCategory = new Array();
                    performanceCase = new Array();
                    powerDevice = new Array();
                    deviceCategory = new Array();
                    boardDevice = new Array();
										platform = new Array();
										powerAdvancedCase = new Array();
										powerAdvCategory = new Array();
                    domParser = new DOMParser();
                    xmlDoc = domParser.parseFromString(msg, 'text/xml');
                    ppat_parsePowerNode();
										ppat_parseAdvancedPowerNode();
                    ppat_parsePerformanceNode();
                    ppat_parseDeviceNode();
                    ppat_parseBoardDevice();
                    generateUI(buildtype);
                    ppat_load_testcase();
              }
            });
}

function ppat_update_checkbox(id,stream, duration){
    $("."+id).attr("checked",true);
    testcases += "{\"CaseName\":\"" + id + "\",";
    testcases += "\"Stream\":\"" + stream + "\",";
    testcases += "\"Duration\":\"" + duration + "\"},";
}

function showAPM(id,target){
 if($("#"+id).attr("checked")){
    $("#"+target).css("display", "block");
    }else{
    $("#"+target).css("display", "none");
    }
}

function addCmd(){
	$("#add").before("<div id=\"div_" + countOfCmds + "\"></div>");
	$("#div_" + countOfCmds).append("<b>Please input commands before run test cases:</b></br>");
    $("#div_" + countOfCmds).append("Description of set of cmds:<input id=" + countOfCmds + "r type=\"text\" name=\"reason\"></input> </br><textarea id=" + countOfCmds + " cols=\"60\" rows=\"10\"></textarea><img src=\"delete.png\" onclick=\"demiss(div_" + countOfCmds + ")\"></img></br>");
    countOfCmds +=1;
}
function demiss(id){
	$(id).remove();
}

function ppat_load_testcase(){
    var audioURL = "http://10.38.32.97:3000/tc/audio";
    $.ajax({
        type: "GET",
        url: audioURL,
        timeout:3000,
        dataType:'html',
        success: function(data){
             var audio_xml = new DOMParser().parseFromString(data, 'text/xml');
             $(audio_xml).find('Resource').each(function(i){
                  var audio = '<input align=\"left\" onclick=ppat_update_checkbox(\"mp3\",\"'+ $(this).find("Name").text() + '\",\"'+ $(this).find("Duration").text() +'\") type=\"radio\" name=\"testcase_audio\" value=\"testcase_audio\">'+ $(this).find("Name").text() + '</input></br>';
                  audio +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Duration:' + '</b>' +$(this).find("Duration").text() + 's</div>';
                  audio +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Description:' + '</b>' +$(this).find("Description").text() +'</div>';

                  $("#mp3").append(audio);
            });

        }
    });
    var videoURL = "http://10.38.32.97:3000/tc/video";
    $.ajax({
        type: "GET",
        url: videoURL,
        timeout:3000,
        dataType:'html',
        success: function(msg){
             var video_xml = new DOMParser().parseFromString(msg, 'text/xml');
             $(video_xml).find('Resource').each(function(i){
                 var checkbox = '<input onclick=ppat_update_checkbox(\"' + $(this).find("CaseName").text() + '\",\"'+ $(this).find("Name").text() + '\",\"'+ $(this).find("Duration").text() +'\")  type=\"radio\" name=\"testcase\" value=\"testcase\">'+ $(this).find("Name").text() + '</input></br>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>FPS:' + '</b>' +$(this).find("FPS").text() + '</div>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Duration:' + '</b>' +$(this).find("Duration").text() + 's</div>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"><b>Description:' + '</b>' + $(this).find("Description").text() + '</div>';
                 checkbox +='<div style=\"margin:3px 0 0 0; padding:0 0 0 27px; font-family:Arial; font-size:12px; color:#3b3a2b; line-height:25px; text-decoration:none\"}><b>Description:' + '</b>' + $(this).find("StreamModule").text() + '</div>';
                 $("#" + $(this).find("CaseName").text()).append(checkbox);
            });
        }
    });

}

function ppat_parseBoardDevice(){
	$(xmlDoc).find("Board").each(function(){
		var str = "{";
		str += "\"type\":\"" + $(this).find("Type").text() + "\",";
		var modules = new Array();
		$(this).find("Name").each(function(){
			modules.push($(this).text());
		});
		str += "\"hw\":\"" + modules.join(";") + "\"";
        str += "}";
        boardDevice.push(eval('(' + str + ')'));
	});
}

function ppat_parseDeviceNode(){
	$(xmlDoc).find("Device").each(function(){
		var str = "{";
		str += "\"name\":\"" + $(this).find("Name").text() + "\",";
		var cases = new Array();
		$(this).find("CaseName").each(function(){
			//powerCategory.push($(this).attr("Component"));
			deviceCategory.push($(this).attr("Category"));
			cases.push($(this).text());
		});
		str += "\"TestCase\":\"" + cases + "\"";
        str += "}";
        powerDevice.push(eval('(' + str + ')'));
	});
}

function ppat_parsePowerNode(){
	$(xmlDoc).find("Power").each(function(){
		powerCase.push($(this).find("CaseName").text());
		powerCategory.push($(this).find("Category").text());
	});
}

function ppat_parseAdvancedPowerNode(){
	$(xmlDoc).find("PowerAdvanced").each(function(){
		powerAdvancedCase.push($(this).find("CaseName").text());
		platform.push($(this).find("Platform").text());
		powerAdvCategory.push($(this).find("Category").text());
	});
}

function ppat_parsePerformanceNode(){
	$(xmlDoc).find("Performance").each(function(){
		performanceCase.push($(this).find("CaseName").text());
	});
}

function chooseTest(select){
	testType = $(select).val();
	if($(select).val() == "PowerScenario"){
		addScenarioCheckbox();
		addUIScenarioCheckbox();
		var tunediv = $("#tune");
		tunediv.empty();
	}else if($(select).val() == "Tune"){
		addScenarioCheckbox();
		addUIScenarioCheckbox();
		//add tune parameters here
		ppat_load_tune();
	}else{
		var tunediv = $("#tune");
		tunediv.empty();
	}
}

function ppat_load_tune(){
    var tuneURL = "http://10.38.32.97:3000/tc/tune";
		var tunediv = $("#tune");
		tunediv.empty();
    $.ajax({
        type: "GET",
        url: tuneURL,
        timeout:3000,
        dataType:'html',
        success: function(data){
             var tune_xml = new DOMParser().parseFromString(data, 'text/xml');
             $(tune_xml).find("Device").each(function(){
							 if($(this).attr("name") == device){
									tunediv.append("<label><b>Tune Parameters:</b></label></br>");
									$(this).find("cpu").each(function(){
										tunediv.append("<label>CPU:</label></br>")
										$(this).children().each(function(){
												var nodeName = $(this).context.nodeName;
												if($(this).text() == null || $(this).text() == ""){
												    var div = "<div class=\"cpu\"><label>Input tune " + nodeName + ": </label>";
														div += "<input type=\"text\" name=\"cpu\" param=\"" + nodeName + "\"> split with ','";
														tunediv.append(div + "</div>");
												}else{
												  var div = "<div class=\"cpu\"><label>select tune " + nodeName + ":</label>";
													var params = $(this).text().split(",");
		                 			for(var i = 0; i < params.length; i++){
														div +="<input type=\"checkbox\" value=\"" + params[i] + "\"" + " name=\"cpu\" param=\"" + nodeName +"\">" + params[i];
													}
													tunediv.append(div + "</div>");
											 }
										});
									});
								 $(this).find("gpu").each(function(){
										var unit = $(this).attr("unit");
										tunediv.append("<label>GPU" +unit + ":</label>")

										$(this).children().each(function(){
												var nodeName = $(this).context.nodeName;
												if($(this).text() == null || $(this).text() == ""){
												    var div = "<div class=\"gpu" + unit + "\"><label>Input tune " + nodeName + ": </label>";
														div += "<input type=\"text\" name=\"vpu\" param=\"" + nodeName + "\"> split with ','";
														tunediv.append(div + "</div>");
												}else{
												  var div = "<div class=\"gpu" + unit + "\"><label>select tune " + nodeName + ":</label>";
													var params = $(this).text().split(",");
		                 			for(var i = 0; i < params.length; i++){
														div +="<input type=\"checkbox\" value=\"" + params[i] + "\"" + " name=\"gpu\" param=\"" + nodeName +"\">" + params[i];
													}
													tunediv.append(div + "</div>");
											 }
										});
									});	
								 $(this).find("vpu").each(function(){
										var unit = $(this).attr("unit");
										tunediv.append("<label>VPU" +unit + ":</label>")

										$(this).children().each(function(){
												var nodeName = $(this).context.nodeName;
												if($(this).text() == null || $(this).text() == ""){
												    var div = "<div class=\"vpu" + unit + "\"><label>Input tune " + nodeName + ": </label>";
														div += "<input type=\"text\" name=\"vpu\" param=\"" + nodeName+ "\"> split with ','";
														tunediv.append(div + "</div>");
												}else{
												  var div = "<div class=\"vpu" + unit + "\"><label>select tune " + nodeName + ":</label>";
													var params = $(this).text().split(",");
		                 			for(var i = 0; i < params.length; i++){
														div +="<input type=\"checkbox\" value=\"" + params[i] + "\"" + " name=\"vpu\" param=\"" + nodeName +"\">" + params[i];
													}
													tunediv.append(div + "</div>");
											 }
										});
									});	
								 $(this).find("ddr").each(function(){
										tunediv.append("<label>DDR:</label>")
										$(this).children().each(function(){
												var nodeName = $(this).context.nodeName;
												if($(this).text() == null || $(this).text() == ""){
												    var div = "<div class=\"ddr\"><label>Input tune " + nodeName + ": </label>";
														div += "<input type=\"text\" name=\"ddr\" param=\"" + nodeName + "\"> split with ','";
														tunediv.append(div + "</div>");
												}else{
												  var div = "<div class=\"ddr\"><label>select tune " + nodeName + ":</label>";
													var params = $(this).text().split(",");
		                 			for(var i = 0; i < params.length; i++){
														div +="<input type=\"checkbox\" value=\"" + params[i] + "\"" + " name=\"ddr\" param=\"" + nodeName +"\">" + params[i];
													}
													tunediv.append(div + "</div>");
											 }
										});
									});	
								}
            });
        }
    });
}

function generateUI(buildtype){

    var submit;
    if(buildtype == "ppat_test"){
        $("#odvb_ppat").html("");
        $("#org_ppat").html("");
        submit = $("#org_ppat");
    }else {
        $("#org_ppat").html("");
        $("#odvb_ppat").html("");
        submit = $("#odvb_ppat");
    }
    var colorbox = "<div style='display:none'>" +
                                     "<div id='1080p' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='720p' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='VGA' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">video</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" +
                                     "<div id='mp3' style=\"padding:10px; background:#F9F7DB;\" ><div style=\"font-family:Arial; font-size:14px; color:#3b3a2b; line-height:25px; text-decoration:none\">If you need update the stream please visit <b style=\"color:#f00;\">\\\\10.38.116.40\\PPAT_test</b>, push your stream in <b style=\"color:#f00;\">audio</b> folder, and update the <b style=\"color:#f00;\">config.xml</b></div></div>" ;

	submit.append("<div id=\"powercase\" style=\"display: block; \">"
					+ "*Choose Test: <select onchange=\"chooseTest(this)\"><option>PowerScenario</option>"
					+ "<option>Tune</option></select></div>");
	submit.append("<label id=\"DeviceHW\" style=\"display: block; \"><b>Choose Board HW Module:</b></label>"); 
	submit.append("<div id=\"scenario\" style=\"display: block; \"></div>");
	submit.append("<div id=\"advscenario\" style=\"display: block; \"></div>");
	submit.append("<div id=\"ui\" style=\"display: block; \"></div>");
	addScenarioCheckbox();
	addUIScenarioCheckbox();
	submit.append(colorbox);
	submit.append("<hr><div id=\"cmd\" style=\"display: block; \"></div>"); 
	submit.append("<div id=\"tune\" style=\"display: block; \">");  
	submit.append("<input id=\"add\" type=\"button\" onclick=\"addCmd()\" value=\"Add cmds for PPAT test\">");
	submit.append("</br>Test loop:<input id=\"loopPPAT\" style=\"width:20px\" type=\"text\" name=\"loopPPAT\" /><span style=\" font-size:12px;color:#999999\">test loop, default is<b>\"3\"</b></span>");

}

function addAdvancedScenarioCheckbox(pf){
	var adv_scenario_div = $("#advscenario");
	adv_scenario_div.html("");
	adv_scenario_div.append("<label><b>Advanced Power Consumption Test:</b></label></br>");
	//add advanced power case
	var hasAdv = false;
	for(var i = 0; i < powerAdvancedCase.length; i++){
		if(platform[i] == pf){
			hasAdv = true;
			adv_scenario_div.append("<input id=\"" + powerAdvancedCase[i] + "\" type=\"checkbox\" value=\"" + powerAdvCategory[i] + "\"" + " name=\"powerAdv\" class=\"" + powerAdvancedCase[i] + "\" text=\""+ powerAdvancedCase[i] +"\">" + powerAdvancedCase[i]);
		}
    }
	if(hasAdv){
		//add button to select/de-select all
		adv_scenario_div.append("</br><input type=\"button\" name=\"SelectAll\" value=\"Select All\" onclick=\"ppat_CheckboxSelectAll('powerAdv', this)\">");
		//add button to select/de-select by category
		powerAdvCategory = powerAdvCategory.del();
		for(var i = 0; i < powerAdvCategory.length; i++){
			adv_scenario_div.append("<input type=\"button\" name=\"Select " + powerAdvCategory[i] + "\" value=\"Select " + powerAdvCategory[i] + "\" onclick=\"ppat_CheckboxSelectCategory('powerAdv', '"+ powerAdvCategory[i] +"',this)\">");
		}
	}
}

function addScenarioCheckbox(){
	var scenario_div = $("#scenario");
	scenario_div.html("");
	scenario_div.append("<hr>");
	scenario_div.append("<label><b>Power Consumption Test:</b></label></br>");
	for(var i = 0; i < powerCase.length; i++){
        scenario_div.append("<input type=\"checkbox\" value=\"" + powerCategory[i] + "\"" + " name=\"power\" class=\"" + powerCase[i] + "\" text=\""+ powerCase[i] +"\" href=\"#"+ powerCase[i] +"\">" + powerCase[i]);
    }

	//add button to select/de-select all
	$("#btn_power").remove();
	scenario_div.after("<div id=\"btn_power\"></div>");
	var btn_pwr_div = $("#btn_power");
	btn_pwr_div.append("<input type=\"button\" name=\"SelectAll\" value=\"Select All\" onclick=\"ppat_CheckboxSelectAll('power', this)\">");
	
	//add button to select/de-select by category
    powerCategory_b = powerCategory;
    powerCategory_b = powerCategory_b.del();
    for(var i = 0; i < powerCategory_b.length; i++){
		btn_pwr_div.append("<input type=\"button\" name=\"Select " + powerCategory_b[i] + "\" value=\"Select " + powerCategory_b[i] + "\" onclick=\"ppat_CheckboxSelectCategory('power', '"+ powerCategory_b[i] +"',this)\">");
    }
	addAdvancedScenarioCheckbox("pxa1928dkb_tz:pxa1928dkb");
		
   $(".1080p").colorbox({inline:true, width:"50%"});
   $(".720p").colorbox({inline:true, width:"50%"});
   $(".VGA").colorbox({inline:true, width:"50%"});
   $(".mp3").colorbox({inline:true, width:"50%"});
}

function addUIScenarioCheckbox(){
	var scenario_div = $("#ui");
	scenario_div.html("");
	scenario_div.append("<hr>");
	scenario_div.append("<label><b>UI Performance Test:</b></label></br>");
	for(var i = 0; i < performanceCase.length; i++){
        scenario_div.append("<input id=\"" + performanceCase[i] + "\" type=\"checkbox\" value=\"" + performanceCase[i] + "\"" + " name=\"performance\" class=\"" + performanceCase[i] + "\" text=\""+ performanceCase[i] +"\">" + performanceCase[i]);
    }

	//add button to select/de-select all
	scenario_div.append("</br><input type=\"button\" name=\"SelectAll\" value=\"Select All\" onclick=\"ppat_CheckboxSelectAll('performance', this)\">");
}

function ppat_appendToText(v){
    var jsonStr = "";
    var caseCount = 0;
		var scenarios = $("#scenario").find("input");
		scenarios.each(function(){
			if($(this).attr("checked")){
				 caseCount += 1;
         jsonStr += "{\"Name\":\"" + $(this).attr("text") + "\"},"
			}
		});
		var advscenarios = $("#advscenario").find("input");
		advscenarios.each(function(){
			if($(this).attr("checked")){
				 caseCount += 1;
         jsonStr += "{\"Name\":\"" + $(this).attr("text") + "\"},"
			}
		});
		var ui = $("#ui").find("input");
		ui.each(function(){
			if($(this).attr("checked")){
				 caseCount += 1;
         jsonStr += "{\"Name\":\"" + $(this).attr("text") + "\"},"
			}
		});
		if(caseCount >= 1){
			jsonStr = "{\"TestCaseList\":[" + jsonStr.substring(0, jsonStr.length - 1) + "]";
      for(var c = 1; c <= countOfCmds; c++){
         if($("#"+c).val() != "" && $("#"+c).val() != null){
           jsonStr +=",\"inputs\":[";
           break;
         }
      }
			$('textarea').each(function(){                      
         var text = $(this).val();//commands
         if(text != ""){
            var description = $("#" + ($(this).attr("id")+ "r")).attr("value");//reason
            if(description == ""){
              description = "null";
            }
            jsonStr += "{\"description\":\"" + description + "\",";
            jsonStr += "\"commands\":\"" + text + "\"},";
          }
       });
       jsonStr = jsonStr.substring(0, jsonStr.length - 1) + "]";
       //loop
       var lp = $("#loopPPAT").val();
       if(lp != ""){
       	jsonStr +=",\"count\":\"" + $("#loopPPAT").val() + "\"";
       }
       if(testcases != ""){
          jsonStr += ",\"stream\":[" + testcases.substring(0, testcases.length - 1) + "]";
        }
				var tuneParam ="";
//CPU
				var cpu = "";
			  var tune = $(".cpu").each(function(){
					var param = "";
					var paramVal = "";
					$(this).find("input").each(function(){
						if($(this).attr("param") != param){
							param = $(this).attr("param");
							paramVal = "";
						}
						if($(this).attr("type") == "checkbox"){
							if($(this).attr("checked")){
								paramVal += $(this).attr("value") + ",";
							}
						}else{//text
							if($(this).val() != ""){
								paramVal += $(this).val() + ",";
							}
						}
					});
					if(paramVal != ""){
						cpu += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
					}
				});
				if(cpu != ""){
					cpu = "\"cpu\":{" + cpu.substring(0,cpu.length-1) + "},";
					tuneParam += cpu;
				}
//DDR
				var ddr = "";
			  var tune = $(".ddr").each(function(){
					var param = "";
					var paramVal = "";
					$(this).find("input").each(function(){
						if($(this).attr("param") != param){
							param = $(this).attr("param");
							paramVal = "";
						}
						if($(this).attr("type") == "checkbox"){
							if($(this).attr("checked")){
								paramVal += $(this).attr("value") + ",";
							}
						}else{//text
							if($(this).val() != ""){
								paramVal += $(this).val() + ",";
							}
						}
					});
					if(paramVal != ""){
						ddr += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
					}
				});
				if(ddr != ""){
					ddr = "\"ddr\":{" + ddr.substring(0,ddr.length-1) + "},";
					tuneParam += ddr;
				}
//gpu0
				var gpu0 = "";
			  var tune = $(".gpu0").each(function(){
					var param = "";
					var paramVal = "";
					$(this).find("input").each(function(){
						if($(this).attr("param") != param){
							param = $(this).attr("param");
							paramVal = "";
						}
						if($(this).attr("type") == "checkbox"){
							if($(this).attr("checked")){
								paramVal += $(this).attr("value") + ",";
							}
						}else{//text
							if($(this).val() != ""){
								paramVal += $(this).val() + ",";
							}
						}
					});
					if(paramVal != ""){
						gpu0 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
					}
				});
				if(gpu0 != ""){
					gpu0 = "\"gpu0\":{" + gpu0.substring(0,gpu0.length-1) + "},";
					tuneParam += gpu0;
				}
//gpu1
				var gpu1 = "";
			  var tune = $(".gpu1").each(function(){
					var param = "";
					var paramVal = "";
					$(this).find("input").each(function(){
						if($(this).attr("param") != param){
							param = $(this).attr("param");
							paramVal = "";
						}
						if($(this).attr("type") == "checkbox"){
							if($(this).attr("checked")){
								paramVal += $(this).attr("value") + ",";
							}
						}else{//text
							if($(this).val() != ""){
								paramVal += $(this).val() + ",";
							}
						}
					});
					if(paramVal != ""){
						gpu1 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
					}
				});
				if(gpu1 != ""){
					gpu1 = "\"gpu1\":{" + gpu1.substring(0,gpu1.length-1) + "},";
					tuneParam += gpu1;
				}
//vpu0
				var vpu0 = "";
			  var tune = $(".vpu0").each(function(){
					var param = "";
					var paramVal = "";
					$(this).find("input").each(function(){
						if($(this).attr("param") != param){
							param = $(this).attr("param");
							paramVal = "";
						}
						if($(this).attr("type") == "checkbox"){
							if($(this).attr("checked")){
								paramVal += $(this).attr("value") + ",";
							}
						}else{//text
							if($(this).val() != ""){
								paramVal += $(this).val() + ",";
							}
						}
					});
					if(paramVal != ""){
						vpu0 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
					}
				});
				if(vpu0 != ""){
					vpu0 = "\"vpu0\":{" + vpu0.substring(0,vpu0.length-1) + "},";
					tuneParam += vpu0;
				}
//vpu1
				var vpu1 = "";
			  var tune = $(".vpu1").each(function(){
					var param = "";
					var paramVal = "";
					$(this).find("input").each(function(){
						if($(this).attr("param") != param){
							param = $(this).attr("param");
							paramVal = "";
						}
						if($(this).attr("type") == "checkbox"){
							if($(this).attr("checked")){
								paramVal += $(this).attr("value") + ",";
							}
						}else{//text
							if($(this).val() != ""){
								paramVal += $(this).val() + ",";
							}
						}
					});
					if(paramVal != ""){
						vpu1 += "\"" + param +"\":\"" + paramVal.substring(0,paramVal.length-1) +"\",";
					}
				});
				if(vpu1 != ""){
					vpu1 = "\"vpu1\":{" + vpu1.substring(0,vpu1.length-1) + "},";
					tuneParam += vpu1;
				}
//all tune append to jsonStr
				if(tuneParam != ""){
					jsonStr += ",\"TuneParam\":{" + tuneParam.substring(0,tuneParam.length-1) + "}";
				}
        jsonStr += "}";
        jsonStr = jsonStr.replace(/[\n]/ig,'&amps;').replace(/\s+/g,'&nbsp;');

				$("input[name='" + v + "']").each(function(){
						$(this).attr("value", jsonStr);
				});
    }else{
        alert('Please at least choose a Power or Performance test case');
    }
}


function ppat_addDeviceCase(j){
		var scenario_div = $("#scenario");
		scenario_div.html("");
		var btn_pwr_div = $("#btn_power");
		btn_pwr_div.remove();
		addScenarioCheckbox();
		btn_pwr_div = $("#btn_power");
		$(xmlDoc).find("Device").each(function(){
		if($(this).find("Name").text() == powerDevice[j].name){
			$(this).find("CaseName").each(function(){
				scenario_div.append("<input id=\"" + $(this).text() + "\" type=\"checkbox\" value=\"" + $(this).attr("Category") + "\"" + " name=\"power\" class=\"" + $(this).text() + "\">" + $(this).text());
			});
		}
	});
		//add button
		deviceCategory = deviceCategory.del();
    	for(var i = 0; i < deviceCategory.length; i++){
			btn_pwr_div.append("<input type=\"button\" name=\"Select " + deviceCategory[i] + "\" value=\"Select " + deviceCategory[i] + "\" onclick=\"ppat_CheckboxSelectCategory('power', '"+ deviceCategory[i] +"',this)\">");
    }
		
}

function ppat_CheckboxSelectAll(name, button) {
	if($(button).attr("value") == "Select All"){
		$(":checkbox").each(function(){
			if($(this).attr("name") == name){
				$(this).attr("checked", true);
			}
		});
		$(button).attr("value","Clear All");
	}else{
		$(":checkbox").each(function(){
			if($(this).attr("name") == name){
				$(this).attr("checked", false);
			}
		});
		$(button).attr("value","Select All");
	}
  }

function ppat_CheckboxSelectCategory(name, Category, button) {
    if($(button).attr("value") == "Select " + Category){
		$(":checkbox").each(function(){
			if($(this).attr("name") == name && $(this).attr("value") == Category){
				$(this).attr("checked", true);
			}
		});
		$(button).attr("value","Clear " + Category);
	}else{
		$(":checkbox").each(function(){
			if($(this).attr("name") == name && $(this).attr("value") == Category){
				$(this).attr("checked", false);
			}
		});
		$(button).attr("value","Select " + Category);
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
        if (selected.value == "ppat_test")
        {
            //load append ppat.xml to Text after validate
            ppat_appendToText("property3value");
//            if (ppat_validateRequired(property4value, "please input the Reason for Build") == false)
//            {
//                property4value.focus();
//                return false;
//            }
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
        }
        if (selected.value == "on_demand_virtual_build_with_ppat")
        {
            //load append ppat.xml to Text after validate
            ppat_appendToText("property2value");
//            if (ppat_validateRequired(property4value, "please input the Reason for Build") == false)
//            {
//                property4value.focus();
//                return false;
//            }
            if (ppat_validateRequired(property6value, "please input the manifest") == false)
            {
                property6value.focus();
                return false;
            }
            if (ppat_validateRequired(property8value, "please select the device") == false)
            {
                property8value.focus();
                return false;
            }
            if (ppat_validateRequired(property9value, "please select the blf") == false)
            {
                property9value.focus();
                return false;
            }
            if (ppat_validateRequired(property2value, "please select power or performance test cases") == false)
            {
                property2value.focus();
                return false;
            }
        }

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

function branchSelect2(){
        var c = {
                "pxa1L88dkb_def:pxa1L88dkb":['HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_1GB.blf'],
                "pxa1U88dkb_def:pxa1U88dkb":['HLN2_Nontrusted_LPDDR3_2G_Hynix.blf'],
                "pxa1928dkb_tz:pxa1928dkb":['PXA1928_Trusted_eMMC_Samsung_Discrete.blf','PXA1928_Trusted_eMMC_Elpida.blf', 'PXA1928_Trusted_eMMC_Hynix.blf', 'PXA1928_Trusted_eMMC_Hynix_Discrete.blf']
                };

        var sel = document.getElementById("property6value");
        var op = sel.options[sel.selectedIndex];
        var r_devices = c[op.text];
        var r_device = document.getElementById("property7value");
        r_device.length=0;
        for(var i=0;i<r_devices.length;i++){
        var ops = new Option();
        ops.text = r_devices[i] ;
        r_device.options[i] = ops;
        }
				device = op.text;
        $("#DeviceHW").css("display", "none");
				$("#DeviceHW").empty();
        $("#device_module").remove();
        $("#DeviceHW").append("<div id=\"device_module\"></div>");
        for(var i = 0; i < boardDevice.length; i++){
            if(boardDevice[i].type == op.text){
                var hwModule = new Array();
                hwModule = boardDevice[i].hw.split(";");
                for(var k = 0; k < hwModule.length; k++){
                    for(var j = 0; j < powerDevice.length; j++){
                        if(powerDevice[j].name == hwModule[k]){
                            $("#DeviceHW").css("display", "block");
							$("#DeviceHW").append("<input id=\"" + powerDevice[j].name + "\" type=\"radio\" value=\"" + powerDevice[j].name + "\"" + " name=\"device\" onclick=ppat_addDeviceCase(" + j + ")>" + powerDevice[j].name);
                        }
                     }
                 }
            }
        }
			addScenarioCheckbox();
		if(testType == "Tune"){
			ppat_load_tune();
		}
}

function branchSelect3(){
        var c = {
                "pxa1L88dkb_def:pxa1L88dkb":['HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_400MHZ_768MB.blf', 'HELN_LTE_LWG_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_768MB.blf', 'HELN_LTE_LWG_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Nontrusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB.blf', 'HELN_LTE_LWG_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_TABLET_Trusted_eMMC_DDR3L_533MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_400MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_400MHZ_1GB_NTZ.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB.blf', 'HELN_LTE_NOCP_Nontrusted_eMMC_533MHZ_512M.blf', 'HELN_LTE_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_CSFB_Trusted_eMMC_533MHZ_1GB_NTZ.blf', 'HELN_LTE_Nontrusted_eMMC_400MHZ_1GB.blf'],
                "pxa1U88dkb_def:pxa1U88dkb":['HLN2_Nontrusted_LPDDR3_2G_Hynix.blf'],
                "pxa1928dkb_tz:pxa1928dkb":['PXA1928_Trusted_eMMC_Samsung_Discrete.blf','PXA1928_Trusted_eMMC_Elpida.blf', 'PXA1928_Trusted_eMMC_Hynix.blf', 'PXA1928_Trusted_eMMC_Hynix_Discrete.blf']
                };

        var sel = document.getElementById("property8value");
        var op = sel.options[sel.selectedIndex];
        var r_devices = c[op.text];
        var r_device = document.getElementById("property9value");
        r_device.length=0;
        for(var i=0;i<r_devices.length;i++){
        var ops = new Option();
        ops.text = r_devices[i] ;
        r_device.options[i] = ops;
        }
				device = op.text;
				$("#DeviceHW").css("display", "none");
				$("#DeviceHW").empty();
        $("#device_module").remove();
        $("#DeviceHW").append("<div id=\"device_module\"></div>");
        for(var i = 0; i < boardDevice.length; i++){
            if(boardDevice[i].type == op.text){
                var hwModule = new Array();
                hwModule = boardDevice[i].hw.split(";");
                for(var k = 0; k < hwModule.length; k++){
                    for(var j = 0; j < powerDevice.length; j++){
                        if(powerDevice[j].name == hwModule[k]){
                            $("#DeviceHW").css("display", "block");
							$("#DeviceHW").append("<input id=\"" + powerDevice[j].name + "\" type=\"radio\" value=\"" + powerDevice[j].name + "\"" + " name=\"device\" onclick=ppat_addDeviceCase(" + j + ")>" + powerDevice[j].name);
                        }
                     }
                 }
            }
        }
			addScenarioCheckbox();
			if(testType == "Tune"){
			ppat_load_tune();
		}
}
