function update_scenario_by_task(task_id){
	var task_url = "ondemand/get_task_detail?task_id=" + task_id;
	$.ajax({
		type: "GET",
		url: task_url,
		success: function(msg){
			alert(msg);
			$("task_scenario").html("");
			$("task_scenario").html(msg);
		}
	});
}

function say(){
	alert("hello");
}