var refreshInterval;
$(document).ready(function(){
	
	reset(); 
	refreshJobList();

	$('#noOfPatient').keyup(function(){
		removeWarningBorder('noOfPatient');
		if (this.value === '') {
			disableInputElements(false,true,true,true,true);
			return
		}
		enableInputElements(true,true,true,false,false);
	});


	$('#noOfEpisode').keyup(function(){
		if (this.value === '') {
			disableInputElements(false,false,false,true,true);
			return
		}
		enableInputElements(true,true,true,true,true);
	});

	$('#noOfEpisodeFrom').keyup(function(){
		removeWarningBorder('noOfEpisodeFrom');
		removeWarningBorder('noOfEpisodeTo');
		if ($('noOfEpisodeTo').value != '' ){
			enableInputElements(true,true,true,true,true);
			return
		}
		if (this.value === '') {
			disableInputElements(false,false,false,true,true);
			return
		}
	});
	$('noOfEpisodeTo').keyup(function(){
		removeWarningBorder('noOfEpisodeFrom');
		removeWarningBorder('noOfEpisodeTo');
		if ($('#noOfEpisodeFrom').value != '' ){
			enableInputElements(true,true,true,true,true);
			return
		}
		
		if (this.value === '') {
			disableInputElements(false,false,false,true,true);
			return
		}
	});
	
	$('#appointmentRange').change(function(){
		if (this.value === 'Y') {
			this.value = 'N';
		} else {
			this.value = 'Y';
		}
		
		if (this.value === 'Y') {
			unhideInputText('noOfAppointmentFrom');
			unhideInputText('noOfAppointmentTo');
			hideInputText('noOfAppointment');
		} else {
			hideInputText('noOfAppointmentFrom');
			hideInputText('noOfAppointmentTo');
			unhideInputText('noOfAppointment');
		}
	});


	$('#episodeRange').change(function(){
		if (this.value === 'Y') {
			this.value = 'N';
		} else {
			this.value = 'Y';
		}
		disableInputElements(false,false,false,true,true)
		if (this.value === 'Y') {
			unhideInputText('noOfEpisodeFrom');
			unhideInputText('noOfEpisodeTo');
			hideInputText('noOfEpisode');
		
		} else {
			hideInputText('noOfEpisodeFrom');
			hideInputText('noOfEpisodeTo');
			unhideInputText('noOfEpisode');
		}
	});


	$('#orderRange').change(function(){
		if (this.value === 'Y') {
			this.value = 'N'
		} else {
			this.value = 'Y'
		}
		
		if (this.value === 'Y') {
			unhideInputText('noOfOrderFrom')
			unhideInputText('noOfOrderTo')
			hideInputText('noOfOrder')
		} else {
			hideInputText('noOfOrderFrom')
			hideInputText('noOfOrderTo')
			unhideInputText('noOfOrder')
		}
	});

	$('#observationRange').change(function(){
		if (this.value === 'Y') {
			this.value = 'N';
		} else {
			this.value = 'Y';
		}
		
		if (this.value === 'Y') {
			unhideInputText('noOfObservationFrom');
			unhideInputText('noOfObservationTo');
			hideInputText('noOfObservation');
		} else {
			hideInputText('noOfObservationFrom');
			hideInputText('noOfObservationTo');
			unhideInputText('noOfObservation');
		}
	});

	$('#noOfAppointmentFrom').keyup(function(){
		removeWarningBorder('noOfAppointmentFrom');
		removeWarningBorder('noOfAppointmentTo');
	});
	$('#noOfAppointmentTo').keyup(function(){
		removeWarningBorder('noOfAppointmentFrom');
		removeWarningBorder('noOfAppointmentTo');
	});
	$('#noOfOrderFrom').keyup(function(){
		removeWarningBorder('noOfOrderFrom');
		removeWarningBorder('noOfOrderTo');
	});
	$('#noOfOrderTo').keyup(function(){
		removeWarningBorder('noOfOrderFrom');
		removeWarningBorder('noOfOrderTo');
	});
	$('#noOfObservationFrom').keyup(function(){
		removeWarningBorder('noOfObservationFrom');
		removeWarningBorder('noOfObservationTo');
	});
	$('#noOfObservationTo').keyup(function(){
		removeWarningBorder('noOfObservationFrom');
		removeWarningBorder('noOfObservationTo');
	});
	
	$("form").submit(function (event) {
		event.preventDefault();
		addJob();
	});
	
	$('#next .page-link').click(function(event){
		event.preventDefault();
		reloadTable(this.href);
	});
	
	$('#previous .page-link').click(function(event){
		event.preventDefault();
		reloadTable(this.href);
	});
	
	$('#actionConfirm').click(function(event){
		var action = $('#actions').val();
		
		switch (action) { 
		case '1': 
			var numOfDone = handleAction(deleteJob);
			if (numOfDone == 0){
				showMessage("Please select at least one job !!!", "warning");
			} else {
				setTimeout(function(){refreshJobList();}, 1000);
			}
			
			break;
		case '2': 
			var numOfDone = handleAction(terminateJob); 
			if (numOfDone == 0){
				showMessage("Please select at least one job !!!", "warning");
			} else {
				setTimeout(function(){refreshJobList();}, 1000);
			}
			
			break;
		default:
			showMessage("Please select action option !!!", "warning");
		}

	});
	
	$('#checkAll').change(
    function(){
        if ($(this).is(':checked')) {
            	$('#jobList input[type="checkbox"]').each(function() 
				{   $(this).prop("checked", true);
				});
        } else {
			$('#jobList input[type="checkbox"]').each(function() 
				{   
					$(this).prop("checked", false);
				});
		}
    });
	
	$('#autoRefresh').change(
		function(){
			if (this.value === 'Y') {
				this.value = 'N'
			} else {
				this.value = 'Y'
			}
			
			if (this.value === 'Y') {
				 refreshInterval = setInterval(function () {
					refreshJobList();
				},5000);
			} else {
				clearInterval(refreshInterval);
			}
    });
	
});	

function refreshCheckAll(){
		if ($('#checkAll').is(':checked')) {
            	$('#jobList input[type="checkbox"]').each(function() 
				{   $(this).prop("checked", true);
				});
        } else {
			$('#jobList input[type="checkbox"]').each(function() 
				{   
					$(this).prop("checked", false);
				});
		}
}

function refreshJobList(){
	getJobList(10,null,null,'Y');
}

function handleAction(fCallback){
	var numOfDone = 0;
	$('#jobList input[type="checkbox"]').each(function() 
	{   if ($(this).is(":checked")) {
			let id = this.id.split('-')[1]
			fCallback(id);
			numOfDone += 1;
		}
	});
	return numOfDone;
}

function deleteJob(id){
		//TODO marcus
		var endpoint = location.protocol + '//' + location.host + '/csp/datagen/web/api/job';
		//var endpoint = 'http://localhost:9094/csp/datagen/web/api/job'

		$.ajax({
		  url: endpoint + "/"+id,
		  processData: false,
		  contentType: false,
		  dataType: 'json',
		  type: 'DELETE',
		  success: function(data){
			  if (data.status === 'Success'){
				   showMessage("Job (ID: " + id + ") is deleted.")
			  } else {
				   showMessage(data.message, 'error')
			  }
		  },
		  error: function(jqXhr, textStatus, errorMessage) {
			  showMessage(errorMessage, 'error')
		  }
		});
}

function terminateJob(id){
		//TODO marcus
		//var endpoint =location.protocol + '//' + location.host + '/csp/datagen/web/api/job'
		var endpoint = 'http://localhost:9094/csp/datagen/web/api/job/terminate';

		$.ajax({
		  url: endpoint + "/"+id,
		  processData: false,
		  contentType: false,
		  dataType: 'json',
		  type: 'POST',
		  success: function(data){
			  if (data.status === 'Success'){
				   showMessage("Job (ID: " + id + ") is terminated.")
			  } else {
				   showMessage(data.message, 'error')
			  }
		  },
		  error: function(jqXhr, textStatus, errorMessage) {
			  showMessage(errorMessage, 'error')
		  }
		});
}


function reloadTable(href){
	var paramStr = href.split('?')[1];
	var params = paramStr.split('&');
	
	var count = '';
	var beforeId = '';
	var afterId = '';
	
	$.each (params, function (i, v){
		let arr = v.split('=');
		
		switch(arr[0]) {
			case 'count':
				count = arr[1];
				break;
			case 'beforeId':
				beforeId = arr[1];
				break;
			case 'afterId':
				afterId = arr[1];
				break;			
		  default:
			//do nothing
		} 
	});
	getJobList(count,beforeId,afterId);
}

function removeWarningBorder(id){
	$('#'+id).removeClass("border border-danger")
}
function showMessage(message, type){
	var div = document.createElement("div");
	
	switch (type) { 
	case 'info': 
		var clazz = 'alert-info'
		var prefix = "Info:   "
		break;
	case 'success': 
		var clazz = 'alert-success'
		var prefix = "Success:   "
		break;
	case 'warning': 
		var clazz = 'alert-warning'
		var prefix = "Warning:   "
		break;		
	case 'error': 
		var clazz = 'alert-danger'
		var prefix = "Error:   "
		break;
	default:
		var clazz = 'alert-info'
		var prefix = "Info:   "
}
	
	let id = 'msg_'+$.now()

	div.innerHTML =
	'<div id="'+id+'" class="container">\n'+
		'<div class="alert ' + clazz + ' alert-dismissible fade show position-fixed fixed-top">'+
			'<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>'+
			'<strong>'+prefix+'</strong> '+ message +
		'</div>'+
	'</div>'
	document.body.appendChild(div);
	setTimeout(function() {
    $('#'+id).fadeOut('fast');
	}, 5000); 
}


function hideInputText(id){
	var el = $('#'+id);
	el.addClass('d-none');
	el.val('')
}

function unhideInputText(id){
	$('#'+id).removeClass('d-none');
}

function enableInputElements(isEnablePatientInput, isEnableAppointmentInput, isEnableEpisodeInput,isEnableOrderInput,isEnableObservationInput){

	if (isEnablePatientInput) {
		enableInputElement('noOfPatient');
	}
	if (isEnableAppointmentInput) {
		enableInputElement('noOfAppointment');
		enableInputElement('noOfAppointmentFrom');
		enableInputElement('noOfAppointmentTo');
	}
	if (isEnableEpisodeInput) {
		enableInputElement('noOfEpisode');
		enableInputElement('noOfEpisodeFrom');
		enableInputElement('noOfEpisodeTo');
	}
	if (isEnableOrderInput) {
		enableInputElement('noOfOrder');
		enableInputElement('noOfOrderFrom');
		enableInputElement('noOfOrderTo');
	}
	if (isEnableObservationInput) {
		enableInputElement('noOfObservation');
		enableInputElement('noOfObservationFrom');
		enableInputElement('noOfObservationTo');
	}
}

function disableInputElements(isDisablePatientInput, isDisableAppointmentInput, isDisableEpisodeInput,isDisableOrderInput, isDisableObservationInput){
	
	if (isDisablePatientInput) {
		disableInputElement('noOfPatient');
	}
	if (isDisableAppointmentInput) {
		disableInputElement('noOfAppointment');
		disableInputElement('noOfAppointmentFrom');
		disableInputElement('noOfAppointmentTo');
	}
	if (isDisableEpisodeInput) {
		disableInputElement('noOfEpisode');
		disableInputElement('noOfEpisodeFrom');
		disableInputElement('noOfEpisodeTo');
	}
	if (isDisableOrderInput) {
		disableInputElement('noOfOrder');
		disableInputElement('noOfOrderFrom');
		disableInputElement('noOfOrderTo');
	}
	if (isDisableObservationInput) {
		disableInputElement('noOfObservation');
		disableInputElement('noOfObservationFrom');
		disableInputElement('noOfObservationTo');
	}
}

function disableInputElement(id){
	var el = $('#'+id);
	el.prop( "disabled", true );
	el.val('');
	el.addClass("bg-secondary");
}

function enableInputElement(id){
	var el = $('#'+id);
	el.prop( "disabled", false );
	el.removeClass("bg-secondary");
}


function getJobList(count,beforeId,afterId){
	
	//var endpoint = 'http://localhost:9094/csp/datagen/web/api/job'
	//TODO marcus
	var endpoint =location.protocol + '//' + location.host + '/csp/datagen/web/api/job';
	var paramsObj = new URLSearchParams();
   
	if (count) {paramsObj.append('count', count)}
	if (beforeId) {paramsObj.append('beforeId', beforeId)}
	if (afterId) {paramsObj.append('afterId', afterId)}
	var params = paramsObj.toString()
	if (params != ''){
		endpoint = endpoint + "?" + params
	}
	$.ajax({
	  url: endpoint,
	  processData: false,
	  contentType: false,
	  dataType: 'json',
	  type: 'GET',
	  success: function(data){
		  if (data.status === 'Success'){
			  buildTable(data)
		  } else {
			   showMessage(data.message, 'error')
		  }
	  },
	  error: function(jqXhr, textStatus, errorMessage) {
		  showMessage(errorMessage, 'error')
	  }
	});

}

function buildTable(dataObj){
	console.log(dataObj)
	$('#jobList tbody ').remove();
	$('#jobList').append('<tbody></tbody>')
	var $tbody = $('#jobList tbody');
	$.each(dataObj.results, function (i, obj) {
		var id = '';
		var pid = '';
		var createDateTime = '';
		var completeDateTime = '';
		var status = '';
		
		if (typeof obj.id != "undefined") {id = obj.id}
		if (typeof obj.pid != "undefined") {pid = obj.pid}
		if (typeof obj.createDateTime != "undefined") {createDateTime = convertDateFormat(obj.createDateTime)}
		if (typeof obj.completeDateTime != "undefined") {completeDateTime = convertDateFormat(obj.completeDateTime)}
		if (typeof obj.status != "undefined") {status = obj.status}
		
		$tbody.append( '<tr>' +
		'<td class="col-md-1">' + 
		'<div class="custom-control custom-checkbox">' +
		'<input type="checkbox" class="custom-control-input" id="check-'+ obj.id +'">'+
		'</div>' +
		'<td class="col-md-1">'+ id +'</td>' +
		'<td class="col-md-2">'+ pid  +'</td>' +
		'<td class="col-md-3">'+ createDateTime +'</td>' +
		'<td class="col-md-3">'+ completeDateTime +'</td>' +
		'<td class="col-md-2">'+ status+'</td>' +
		 '</tr>' );

   // console.log(obj.id + ", " + obj.status + ", " + obj.createDateTime + ", " + obj.lastUpdateDateTime);

	});
	
	var nextpage = dataObj.links.nextPage;
	var previousPage = dataObj.links.previousPage;
	var host = location.protocol + '//' + location.host;
	if (typeof nextpage != "undefined" && nextpage != ""){
		$('#next').removeClass( "disabled" ); 
		$('#next .page-link').prop('href',host + nextpage ); //todo marcus
	} else {
		$('#next').addClass( "disabled");
	}
	if (typeof previousPage != "undefined" && previousPage !=""){
		$('#previous').removeClass( "disabled");
		$('#previous .page-link').prop('href',host + previousPage );  //todo marcus
	} else {
		$('#previous').addClass( "disabled");
	}
	
	//console.log(nextpage);
	//console.log(previousPage);
	
}

function addJob(){
	
		var isValid = true;
		
		var numOfPatient = $('#noOfPatient').val();
		var numOfEpisodePerPatient = $('#noOfEpisode').val();
		var numOfOrderPerEpisode = $('#noOfOrder').val();
		var numOfAppointmentPerPatient = $('#noOfAppointment').val();
		var numOfObservationPerEpisode = $('#noOfObservation').val();
		
		var noOfAppointmentFrom = $('#noOfAppointmentFrom').val()
		var noOfAppointmentTo = $('#noOfAppointmentTo').val()
		var noOfEpisodeFrom = $('#noOfEpisodeFrom').val()
		var noOfEpisodeTo = $('#noOfEpisodeTo').val()
		var noOfOrderFrom = $('#noOfOrderFrom').val()
		var noOfOrderTo = $('#noOfOrderTo').val()
		var noOfObservationFrom = $('#noOfObservationFrom').val()
		var noOfObservationTo = $('#noOfObservationTo').val()
		
		
		var isEpisodeRange =  $('#episodeRange').val() === 'Y' && noOfEpisodeFrom != "" && noOfEpisodeTo != "";
		var isOrderRange =  $('#orderRange').val() === 'Y' && noOfOrderFrom != "" && noOfOrderTo != "";
		var isAppointmentRange =  $('#appointmentRange').val() === 'Y' && noOfAppointmentFrom != "" && noOfAppointmentTo != "";
		var isObservationRange =  $('#observationRange').val() === 'Y' && noOfObservationFrom != "" && noOfObservationTo != "";
		
		var isEpisode = numOfEpisodePerPatient > 1;
		var isOrder = numOfOrderPerEpisode > 1;
		var isAppointment = numOfAppointmentPerPatient > 1;
		var isObservation = numOfObservationPerEpisode > 1;
		

		var formData = new FormData();
		
		if (numOfPatient != "") {formData.append('numOfPatient', numOfPatient);}
		if (numOfEpisodePerPatient != "") {formData.append('numOfEpisodePerPatient', numOfEpisodePerPatient);}
		if (numOfOrderPerEpisode != "") {formData.append('numOfOrderPerEpisode', numOfOrderPerEpisode);}
		if (numOfAppointmentPerPatient != "") {formData.append('numOfAppointmentPerPatient', numOfAppointmentPerPatient);}
		if (numOfObservationPerEpisode != "") {formData.append('numOfObservationPerEpisode', numOfObservationPerEpisode);}
		if (isEpisodeRange != "" ) {formData.append('isEpisodeRange', isEpisodeRange ? 1 : 0);}
		if (isOrderRange != "") {formData.append('isOrderRange', isOrderRange ? 1 : 0);}
		if (isAppointmentRange != "") {formData.append('isAppointmentRange', isAppointmentRange ? 1 : 0);}
		if (isObservationRange != "") {formData.append('isObservationRange', isObservationRange ? 1 : 0);}
		if (isEpisode != "") {formData.append('isEpisode', isEpisode ? 1 : 0);}
		if (isOrder != "") {formData.append('isOrder', isOrder ? 1 : 0);}
		if (isAppointment != "") {formData.append('isAppointment', isAppointment ? 1 : 0);}
		if (isObservation != "") {formData.append('isObservation', isObservation ? 1 : 0);}
		
		if (noOfEpisodeFrom != "") {formData.append('minNumOfEpisodePerPatient', noOfEpisodeFrom);}
		if (noOfEpisodeTo != "") {formData.append('maxNumOfEpisodePerPatient', noOfEpisodeTo);}
		if (noOfOrderFrom != "") {formData.append('minNumOfOrderPerEpisode', noOfOrderFrom);}
		if (noOfOrderTo != "") {formData.append('maxNumOfOrderPerEpisode', noOfOrderTo);}
		if (noOfAppointmentFrom != "") {formData.append('minNumOfAppointmentPerPatient', noOfAppointmentFrom);}
		if (noOfAppointmentTo != "") {formData.append('maxNumOfAppointmentPerPatient', noOfAppointmentTo);}
		if (noOfObservationFrom != "") {formData.append('minNumOfObservationPerEpisode', noOfObservationFrom);}
		if (noOfObservationTo != "") {formData.append('maxNumOfObservationPerEpisode', noOfObservationTo);}
		
		//validate the input
		if (numOfPatient == null || numOfPatient < 1){
			isValid = false;
			$('#noOfPatient').addClass("border border-danger")
		} 
		
		if (noOfEpisodeFrom != "" && noOfEpisodeTo == ""){
			isValid = false;
			$('#noOfEpisodeTo').addClass("border border-danger")
		}
		
		if (noOfEpisodeFrom == "" && noOfEpisodeTo != ""){
			isValid = false;
			$('#noOfEpisodeFrom').addClass("border border-danger")
		}
		
		if (noOfEpisodeFrom > noOfEpisodeTo){
			isValid = false;
			$('#noOfEpisodeFrom').addClass("border border-danger")
			$('#noOfEpisodeTo').addClass("border border-danger")
		}
		
		if (noOfOrderFrom != "" && noOfOrderTo == ""){
			isValid = false;
			$('#noOfOrderTo').addClass("border border-danger")
		}
		
		if (noOfOrderFrom == "" && noOfOrderTo != ""){
			isValid = false;
			$('#noOfOrderFrom').addClass("border border-danger")
		}
		
		if (noOfOrderFrom > noOfOrderTo){
			isValid = false;
			$('#noOfOrderFrom').addClass("border border-danger")
			$('#noOfOrderTo').addClass("border border-danger")
		}
		
		if (noOfAppointmentFrom != "" && noOfAppointmentTo == ""){
			isValid = false;
			$('#noOfAppointmentTo').addClass("border border-danger")
		}
		
		if (noOfAppointmentFrom == "" && noOfAppointmentTo != ""){
			isValid = false;
			$('#noOfAppointmentFrom').addClass("border border-danger")
		}
		
		if (noOfAppointmentFrom > noOfAppointmentTo){
			isValid = false;
			$('#noOfAppointmentTo').addClass("border border-danger")
			$('#noOfAppointmentFrom').addClass("border border-danger")
		}
		
		if (noOfObservationFrom != "" && noOfObservationTo == ""){
			isValid = false;
			$('#noOfObservationTo').addClass("border border-danger")
		}
		
		if (noOfObservationFrom == "" && noOfObservationTo != ""){
			isValid = false;
			$('#noOfObservationFrom').addClass("border border-danger")
		}		
		
		if (noOfObservationFrom > noOfObservationTo){
			isValid = false;
			$('#noOfObservationTo').addClass("border border-danger")
			$('#noOfObservationFrom').addClass("border border-danger")
		}
		
		if (!isValid) {
			showMessage("Invalid Input", 'error')
			return
		}
		
	
		
		//var endpoint =location.protocol + '//' + location.host + '/csp/datagen/web/api/addJob'
		var endpoint = 'http://localhost:9094/csp/datagen/web/api/addJob'
		console.log(formData)
		
		
		$.ajax({
		  url: endpoint,
		  data: formData,
		  processData: false,
		  contentType: false,
		  dataType: 'json',
		  type: 'POST',
		  success: function(data){
			  if (data.status === 'Success'){
				   showMessage("Job (ID: " + data.jobId +') is created', 'success')
			  } else {
				   showMessage(data.message, 'error')
			  }
			  reset();
			  moveToTop();
			  refreshJobList();
			 
		  },
		  error: function(jqXhr, textStatus, errorMessage) {
			  showMessage(errorMessage, 'error')
		  }
		});
		

}

function moveToTop(){
	 $('html, body').animate({scrollTop: '0px'}, 0);
}

function reset(){
	$('#noOfPatient').val('');
	$('#noOfEpisode').val('');
	$('#noOfAppointment').val('');
	$('#noOfOrder').val('');
	$('#noOfObservation').val('');

	disableInputElement('noOfEpisode');
	disableInputElement('noOfAppointment');
	disableInputElement('noOfOrder');
	disableInputElement('noOfObservation');

	$('#appointmentRange').val('N')
	$('#appointmentRange').prop("checked", false);
	hideInputText('noOfAppointmentFrom');
	hideInputText('noOfAppointmentTo');
	unhideInputText('noOfAppointment');
		
	$('#episodeRange').val('N');
	$('#episodeRange').prop("checked", false);
	hideInputText('noOfEpisodeFrom');
	hideInputText('noOfEpisodeTo');
	unhideInputText('noOfEpisode');
	
	$('#orderRange').val('N');
	$('#orderRange').prop("checked", false);
	hideInputText('noOfOrderFrom');
	hideInputText('noOfOrderTo');
	unhideInputText('noOfOrder');
	
	$('#observationRange').val('N');
	$('#observationRange').prop("checked", false);
	hideInputText('noOfObservationFrom');
	hideInputText('noOfObservationTo');
	unhideInputText('noOfObservation');
	
	$('#checkAll').prop("checked", false);

	$('#autoRefresh').val('Y');
	$('#autoRefresh').prop("checked", true);
}

function convertDateFormat(dateStr){
	var time = new Date(dateStr);

	var date = time.getDate().toString();
	var month = (time.getMonth() + 1).toString(); 
	var year = time.getFullYear().toString();
	var hour = time.getHours().toString();
	var minute = time.getMinutes().toString();
	var second = time.getSeconds().toString();
	
	date = date.length == 2? date : '0' + date;
	month= month.length == 2? month : '0' + month;
	hour = hour.length == 2? hour : '0' + hour;
	minute = minute.length == 2? minute : '0' + minute;
	second = second.length == 2? second : '0' + second;
	
	return year+ "-"+month+"-"+date +" " + hour+":"+minute+":"+second;
	
}
