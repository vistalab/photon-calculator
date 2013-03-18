<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>Psych 221: Photon Calculator</title>
<link rel="stylesheet" href="style.css" type="text/css" media="screen" />
<script language="javascript" type="text/javascript" src="jquery.min.js"></script>
<%-- <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" ></script>--%>
<link rel="stylesheet" type="text/css" href="css/imgareaselect-default.css" />
<%-- <script type="text/javascript" src="scripts/jquery.min.js"></script>--%>
<script type="text/javascript" src="scripts/jquery.imgareaselect.pack.js"></script>

<%-- jqplot required js's --%>
<!--[if lt IE 9]><script language="javascript" type="text/javascript" src="excanvas.js"></script><![endif]-->

<script language="javascript" type="text/javascript" src="jquery.jqplot.min.js"></script>
<script type="text/javascript" src="plugins/jqplot.json2.min.js"></script>
<script type="text/javascript" src="plugins/jqplot.canvasTextRenderer.js"></script>
<script type="text/javascript" src="plugins/jqplot.canvasAxisLabelRenderer.js"></script>
<link rel="stylesheet" type="text/css" href="jquery.jqplot.css" />
    
<script type="text/javascript">
function preview(img, selection) {
    if (!selection.width || !selection.height)
        return;
    
    var scaleX = 100 / selection.width;
    var scaleY = 100 / selection.height;

    $('#preview img').css({
        width: Math.round(scaleX * document.getElementById("photo").clientWidth),
        height: Math.round(scaleY * document.getElementById("photo").clientHeight),
        marginLeft: -Math.round(scaleX * selection.x1),
        marginTop: -Math.round(scaleY * selection.y1)
    });

    $('#x1').val(selection.x1);
    $('#y1').val(selection.y1);
    $('#x2').val(selection.x2);
    $('#y2').val(selection.y2);
    $('#w').val(selection.width);
    $('#h').val(selection.height);    
}

$(function () {
    $('#photo').imgAreaSelect({ aspectRatio: false, handles: true,
        fadeSpeed: 200, onSelectChange: preview });
});

$(document).ready(function () {
	window.plot2 = $.jqplot('chartIrr',  [[[1, 2],[3,5.12],[5,13.1],[7,33.6],[9,85.9],[11,219.9]]]);
	window.plot3 = $.jqplot('chartRad',  [[[1, 2],[3,5.12],[5,13.1],[7,33.6],[9,85.9],[11,219.9]]]);
	ChangeIll(1); 
});

</script>
<script>
	function loadXMLDoc() {
		var xmlhttp;
		if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
		  xmlhttp=new XMLHttpRequest();
		} else {// code for IE6, IE5
		  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange=function() {
		  if (xmlhttp.readyState==4 && xmlhttp.status==200) {
		    document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
		  }
		}
		xmlhttp.open("GET","demo_get.jsp",true);
		xmlhttp.send();
	}; 
	// this function only needs to change irradiance when set to false
	function ChangeIll(fullChange) {
		var lens = $('input:radio[name=lens]:checked').val();
		var fNo = document.getElementById("fNo").value; 
		var imgName = $('input:radio[name=group1]:checked').val();
		var ill = $('input:radio[name=ill]:checked').val();
		if (ill==undefined) {
			ill = "D65.mat";
		}
		if (imgName==undefined) {
			imgName = "hats.jpg";
		}
		var txt = "<img id=\"photo\" src=\"create_image.jsp?img="+imgName+"&ill="+ill+"\" onload=\"loadImage()\" /> ";
		var txt2 = "<img src=\"create_image.jsp?img="+imgName+"&ill="+ill+"\" style=\"width: 100px; height: 100px;\" /> ";
		console.log(txt);
		// The url for our json data
		if ($('#x1').val() == "-") {
			var jsonRad = "create_rad.jsp?img="+imgName+"&ill="+ill+"&f="+fNo; 
			var jsonIrr = "create_irr.jsp?img="+imgName+"&ill="+ill+"&f="+fNo+"&l="+lens;
		}
		else {
			var jsonRad = "create_rad.jsp?img="+imgName+"&ill="+ill+"&f="+fNo+"&x1="+$('#x1').val()+"&y1="+$('#y1').val()+"&w="+$('#w').val()+"&h="+$('#h').val();
			var jsonIrr = "create_irr.jsp?img="+imgName+"&ill="+ill+"&f="+fNo+"&l="+lens+"&x1="+$('#x1').val()+"&y1="+$('#y1').val()+"&w="+$('#w').val()+"&h="+$('#h').val();
		}
		
		
		console.log(jsonIrr);
		
		if(fullChange) {
			document.getElementById("imageGoesHere").innerHTML=txt;
			document.getElementById("preview").innerHTML=txt2;
			$('#photo').imgAreaSelect({ aspectRatio: '1:1', handles: true,
		        fadeSpeed: 200, onSelectChange: preview });
		}
		// Our ajax data renderer which here retrieves a text file.
		// it could contact any source and pull data, however.
		// The options argument isn't used in this renderer.
		var ajaxDataRenderer = function(url, plot, options) {
		  var ret = null;
		  $.ajax({
		    // have to use synchronous here, else the function 
		    // will return before the data is fetched
		    async: false,
		    url: url,
		    dataType:"json",
		    success: function(data) {
		      ret = data;
		    }
		  });
		  return ret;
		};

		var oldPlot = window.plot2; 
		oldPlot.destroy();
		if (fullChange) {
			oldPlot = window.plot3; 
			oldPlot.destroy();
		}
		// passing in the url string as the jqPlot data argument is a handy
		// shortcut for our renderer.  You could also have used the
		// "dataRendererOptions" option to pass in the url.
		window.plot2 = $.jqplot('chartIrr', jsonIrr,{
			// Turns on animatino for all series in this plot.
	        animate: true,
	        // Will animate plot on calls to plot1.replot({resetAxes:true})
	        animateReplot: true,
			title: "Calculated Irradiance",
			axes:{
				  xaxis:{
				    label:'wavelength (nm)', 
				    min:400, max:700, numberTicks:31
				  },
				  yaxis:{
				    label:'Irradiance (photons / s / m^2 / nm)', 
				    labelRenderer: $.jqplot.CanvasAxisLabelRenderer
				  }
				},
			dataRenderer: ajaxDataRenderer,
		});
		if (fullChange) {
			window.plot3 = $.jqplot('chartRad', jsonRad,{
				// Turns on animatino for all series in this plot.
		        animate: true,
		        // Will animate plot on calls to plot1.replot({resetAxes:true})
		        animateReplot: true,
				title: "Extrapolated Radiance",
				axes:{ xaxis:{}},
				axes:{
				  xaxis:{
				    label:'wavelength (nm)', 
				    min:400, max:700, numberTicks:31
				  },
				  yaxis:{
				    label:'Radiance (photons / s / sr / m^2 / nm)', 
				    labelRenderer: $.jqplot.CanvasAxisLabelRenderer
				  }
				},
				dataRenderer: ajaxDataRenderer,
			});
		}
		var rad = (window.plot3.data)[0].reduce(function(a, b){return [a[0]+b[0],a[1] + b[1]];});
		rad = rad[1]*10;
		document.getElementById("valueRad").innerHTML="Value over 400-700nm: "+rad+" photons / s / sr / m^2";
		var irr = (window.plot2.data)[0].reduce(function(a, b){return [a[0]+b[0],a[1] + b[1]];});
		irr = irr[1]*10;
		document.getElementById("valueIrr").innerHTML="Value over 400-700nm: "+irr+" photons / s / m^2";
	} 
	function loadImage() {
		var o = document.getElementById("imageGoesHere");
		o.style.width = document.getElementById("photo").clientWidth+"px";
		console.log(document.getElementById("photo").clientWidth+"px");
		o.style.height = document.getElementById("photo").clientHeight+"px";
	} 
	function loadSensor() {
		var txt = "<img id=\"photo\" src=\"create_sensor.jsp?img="+"hats.jpg"+"&ill="+"D65.mat"+"\" onload=\"loadImage()\" /> ";
		document.getElementById("sensor_imageGoesHere").innerHTML=txt;
	}
</script>


</head>
<body>
<div id="content" class="container">
<div class="post single">
<h1>Psych 221: Photon Calculator</h1>
<h3>Choose a sample image -- scene radiance will be extrapolated</h3>
<form name="imgSelect"">
<div align="center"><br>
	<input type="radio" name="group1" value="eagle.jpg" onclick="ChangeIll(1)">Eagle
	<input type="radio" name="group1" value="hats.jpg" onclick="ChangeIll(1)" checked>Hats
	<input type="radio" name="group1" value="Ma_Lion_6459.jpg" onclick="ChangeIll(1)">Lion
	<hr>
</div>
</form>

<h3>Choose an illuminant</h3>
<form name="illSelect"">
<div align="center"><br>
	<input type="radio" name="ill" value="D65.mat" onclick="ChangeIll(1)" checked>D65
	<input type="radio" name="ill" value="Fluorescent.mat" onclick="ChangeIll(1)">Fluorescent
	<input type="radio" name="ill" value="Tungsten.mat" onclick="ChangeIll(1)">Tungsten
	<hr>
</div>
</form>

<h3>Choose a region</h3>

<div class="container demo">
  <div style="float: left; width: 70%;">
    <p class="instructions">
      Click and drag on the image to select an area. 
    </p>
 
    <div id="imageGoesHere" class="frame" style="margin: 0 0.3em; width: 300px; height: 300px;">
      <img id="photo" src="flower2.jpg" />
    </div>
  </div>
 
  <div style="float: left; width: 30%;">
    <p style="font-size: 110%; font-weight: bold; padding-left: 0.1em;">
      Selection Preview
    </p>
  
    <div class="frame" 
      style="margin: 0 1em; width: 100px; height: 100px;">
      <div id="preview" style="width: 100px; height: 100px; overflow: hidden;">
        <img src="flower2.jpg" style="width: 100px; height: 100px;" />
      </div>
    </div>

    <table style="margin-top: 1em;">
      <thead>
        <tr>
          <th colspan="2" style="font-size: 110%; font-weight: bold; text-align: left; padding-left: 0.1em;">
            Coordinates
          </th>
          <th colspan="2" style="font-size: 110%; font-weight: bold; text-align: left; padding-left: 0.1em;">
            Dimensions
          </th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td style="width: 10%;"><b>X<sub>1</sub>:</b></td>
 		      <td style="width: 30%;"><input type="text" id="x1" value="-" /></td>
 		      <td style="width: 20%;"><b>Width:</b></td>
   		    <td><input type="text" value="-" id="w" /></td>
        </tr>
        <tr>
          <td><b>Y<sub>1</sub>:</b></td>
          <td><input type="text" id="y1" value="-" /></td>
          <td><b>Height:</b></td>
          <td><input type="text" id="h" value="-" /></td>
        </tr>
        <tr>
          <td><b>X<sub>2</sub>:</b></td>
          <td><input type="text" id="x2" value="-" /></td>
          <td></td>
          <td></td>
        </tr>
        <tr>
          <td><b>Y<sub>2</sub>:</b></td>
          <td><input type="text" id="y2" value="-" /></td>
          <td></td>
          <td><button type="button" onclick="ChangeIll(1)">Confirm region</button></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<div id="radiance">
	<h3>Extrapolated Radiance</h3>
	<p><h4 id="valueRad">Value: </h4></p>
	<div id="chartRad" style="height:400px;"></div>
</div>

<h3>Choose a lens (for transmission calculations)</h3>
<form name="lensSelect"">
<div align="center"><br>
	<input type="radio" name="lens" value="uniformTrans.dat" onclick="ChangeIll(0)" checked>Uniform transmittance
	<input type="radio" name="lens" value="glassTrans.dat" onclick="ChangeIll(0)">Glass lens
	<input type="radio" name="lens" value="cr39Trans.dat" onclick="ChangeIll(0)">CR-39 pink-tint plastic
	<input type="radio" name="lens" value="nikon55Trans.dat" onclick="ChangeIll(0)">Nikon 55mm 
	<hr>
	<h5>Melles Griot visible 80 filter set</h5>
	<input type="radio" name="lens" value="F1Trans.dat" onclick="ChangeIll(0)">Filter 02
	<input type="radio" name="lens" value="F2Trans.dat" onclick="ChangeIll(0)">Filter 04
	<input type="radio" name="lens" value="F3Trans.dat" onclick="ChangeIll(0)">Filter 06
	<input type="radio" name="lens" value="F4Trans.dat" onclick="ChangeIll(0)">Filter 08
	<input type="radio" name="lens" value="F5Trans.dat" onclick="ChangeIll(0)">Filter 12
	<input type="radio" name="lens" value="F6Trans.dat" onclick="ChangeIll(0)">Filter 14
	<input type="radio" name="lens" value="F7Trans.dat" onclick="ChangeIll(0)">Filter 16
	<hr>
	f/#: <input type="text" id="fNo" value="2" />
	<hr>
</div>
</form>

<div id="irradiance">
	<h3>Calculated Irradiance</h3>
	<p><h4 id="valueIrr">Value: </h4></p>
	<div id="chartIrr" style="height:400px;"></div>
</div>


<div id="sensorImage">
	<h3>Absorption histogram for the human eye</h3>
	<p><h4 id="valueIrr">Chart (currently static): </h4></p>
	<div id="sensor_imageGoesHere"  width: 700px; ">
      <img id="photo" src="flower2.jpg" />
    </div>
    <button type="button" onclick="loadSensor(1)">Load sensor data</button>
</div>

<%--
<button type="button" onclick="loadXMLDoc()">Request data</button>
<div id="myDiv"></div>
--%>

<div id="credits">
	<h3>Credits</h3>
	<p>This project uses: </p>
	<ul>
		<li>Matlab/ISET-4.0, developed by ImagEval Consulting, provided by Professor Brian Wandell and Dr. Joyce Farrell; </li>
		<li>matlabcontrol, developed by Joshua Kaplan; </li>
		<li>jqPlot, developed by Chris Leonello; </li>
		<li>imgAreaSelect, developed by Michal Wojciechowski. </li>
	</ul>
	<p>Data credits: </p>
	<ul>
		<li>Nikon 55mm and filters data from <a href="http://www.graphics.cornell.edu/online/measurements/filter-spectra/index.html">NSF Graphics and Visualization Center</a></li>
		<li>Glass and CR-39 data from <a href="http://www.oculist.net/downaton502/prof/ebook/duanes/pages/v1/v1c051d.html">Ophthalmic Lens Tints and Coatings</a> by Gregory L. Stephens and John K. Davis</li> 
	</ul>
</div>		<!-- End credits div  -->
</div>		<!-- End post single div  -->
</div>		<!-- End container div  -->

</body>
</html>