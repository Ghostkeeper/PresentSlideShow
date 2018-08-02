function init() {
	curSlide = 0;
	curItem = 0;
	if(window.location.hash.substring(1) != "") {
		curSlide = parseInt(window.location.hash.substring(1));
	}
	resize();
	show("slide" + curSlide);
	show("slide" + curSlide + "item" + curItem);
	
	updateTimeDisplay();

	document.onkeyup = key;
	window.onresize = resize;
	
	slideEvent();
}

function nextItem() {
	curItem += 1;
	if(curItem >= numitems[curSlide]) {
		if(curSlide >= numslides - 1) { //Last slide. Don't go beyond.
			curItem -= 1; //Undo that.
			return;
		}
		nextSlide();
	}
	var inEffect = document.getElementById("slide" + curSlide + "item" + curItem).getAttribute("in");
	if(inEffect == "fade") { //Fade in effect.
		if(curItem == 0) { //But don't fade in the first item. It's faded by fading out the previous slide.
			show("slide" + curSlide + "item" + curItem);
		} else {
			fadeIn("slide" + curSlide + "item" + curItem);
		}
	} else if(inEffect.substring(0, 5) == "slide") { //Slide in effect.
		slideIn("slide" + curSlide + "item" + curItem,parseFloat(inEffect.substring(5))); //Parse the direction of the slide.
	}
	nextItemEvent();
}

function nextItemEvent() {
	eval("if(typeof event" + curSlide + "x" + curItem + " == 'function') event" + curSlide + "x" + curItem + "();");
}

function slideEvent() {
	eval("if(typeof event" + curSlide + " == 'function') event" + curSlide + "();");
}

function nextSlide() {
	if(curSlide >= numslides - 1) { //Last slide. Don't go beyond.
		return;
	}
	for(var i = 0;i < numitems[curSlide];i += 1) {
		fadeOut("slide" + curSlide + "item" + i);
	}
	document.getElementById("slide" + curSlide).style.zIndex = "1";
	fadeOut("slide" + curSlide);
	curSlide += 1;
	window.location.hash = curSlide;
	curItem = 0;
	resize();
	document.getElementById("slide" + curSlide).style.zIndex = "0";
	show("slide" + curSlide);
	show("slide" + curSlide + "item" + curItem);
	slideEvent();
}

function previousSlide() {
	if(curSlide <= 0) { //First slide. Don't go beyond.
		return;
	}
	for(var i = 0;i < numitems[curSlide];i += 1) {
		fadeOut("slide" + curSlide + "item" + i);
	}
	document.getElementById("slide" + curSlide).style.zIndex = "1";
	fadeOut("slide" + curSlide);
	curSlide -= 1;
	window.location.hash = curSlide;
	curItem = 0;
	resize();
	document.getElementById("slide" + curSlide).style.zIndex = "0";
	show("slide" + curSlide);
	show("slide" + curSlide + "item" + curItem);
	slideEvent();
}

function goToSlide(goalSlide) {
	if(goalSlide <= 0) { //Check bounds.
		goalSlide = 0;
	} else if(goalSlide >= numslides) {
		goalSlide = numslides - 1;
	}
	if(curSlide == goalSlide) {
		return; //Already at this slide.
	}
	for(var i = 0;i < numitems[curSlide];i += 1) {
		fadeOut("slide" + curSlide + "item" + i);
	}
	document.getElementById("slide" + curSlide).style.zIndex = "1";
	fadeOut("slide" + curSlide);
	curSlide = goalSlide;
	window.location.hash = curSlide;
	curItem = 0;
	resize();
	document.getElementById("slide" + curSlide).style.zIndex = "0";
	show("slide" + curSlide);
	show("slide" + curSlide + "item" + curItem);
	slideEvent();
}

function key(e) {
	var id = (window.event) ? event.keyCode : e.keyCode;
	switch(id) {
		case 32: //Spacebar.
		case 34: //Right arrow on laser pointer (page down).
			nextItem();
			break;
		case 33: //Left arrow on laser pointer (page up).
		case 37: //Left arrow.
			previousSlide();
			break;
		case 36: //Home.
			goToSlide(0); //Go to first slide.
			break;
		case 35: //End.
			goToSlide(numslides - 1); //Go to first slide.
			break;
		case 39: //Right arrow.
			nextSlide();
			break;
	}
}

function resize() {
	document.body.style.fontSize = "" + (window.innerWidth / 40) + "px";
	var minusHeight = document.getElementById("header" + curSlide).clientHeight + document.getElementById("footer" + curSlide).clientHeight;
	var iframes = document.getElementsByTagName("iframe");
	Array.prototype.forEach.call(iframes,function(ifr,i) {
		ifr.style.height = (window.innerHeight - minusHeight) + "px";
	});
	var contents = document.getElementsByClassName("content");
	Array.prototype.forEach.call(contents,function(cont,i) {
		cont.style.height = (window.innerHeight - minusHeight) + "px";
	});
}

function getStyle(elementId,property) {
	var element = document.getElementById(elementId);
	if(element.currentStyle) { //FF and Chrome
		return element.currentStyle[property];
	} else { //IE
		return document.defaultView.getComputedStyle(element,null).getPropertyValue(property);
	}
}

function format(num) {
	if(num < 10) {
		return "0" + num;
	} else {
		return num.toString();
	}
}

function updateTimeDisplay() {
	var dd = new Date();
	clocks = document.getElementsByClassName("clock"); //Get all clocks on every slide.
	for(i = 0,len = clocks.length;i < len;i++) {
		clocks[i].innerHTML = "" + dd.getHours() + ":" + format(dd.getMinutes()) + ":" + format(dd.getSeconds());
	}
	setTimeout(updateTimeDisplay,1000); //Update again after 1 second.
}

function fadeIn(element) {
	var elem = document.getElementById(element);
	var opacity = 0; //Initial opacity.
	elem.style.visibility = "visible"; //But start rendering.
	var timer = setInterval(function() {
		if(opacity >= 1) { //Termination criterium.
			clearInterval(timer);
		}
		elem.style.opacity = opacity;
		elem.style.filter = "alpha(opacity=" + opacity * 100 + ")"; //Legacy browsers.
		opacity += (1.1 - opacity) * 0.1; //First transitions fast, then slows down towards maximum opacity.
		if(opacity > 1) opacity = 1; //Shouldn't cause any trouble, but let's just make sure opacity never goes above 1.
	},10); //Execute this every 10ms.
}

function fadeOut(element) {
	var elem = document.getElementById(element);
	var opacity = 1; //Initial opacity.
	var timer = setInterval(function() {
		if(opacity <= 0) { //Termination criterium.
			clearInterval(timer);
			elem.style.visibility = "hidden"; //Makes rendering a bit more efficient and prevents button presses on some browsers.
		}
		elem.style.opacity = opacity;
		elem.style.filter = "alpha(opacity=" + opacity * 100 + ")"; //Legacy browsers.
		opacity -= (0.1 + opacity) * 0.1; //First transitions fast, then slows down towards zero opacity.
		if(opacity < 0) opacity = 0; //Shouldn't cause any trouble, but let's just make sure opacity never goes below 0.
	},10); //Execute this every 10ms.
}

/**
 * Immediately shows the element, rather than fading in, but prepares it to be properly faded later.
 */
function show(element) {
	var elem = document.getElementById(element);
	elem.style.visibility = "visible";
	elem.style.opacity = 1;
}

/**
 * Immediately hides the element, rather than fading out, but prepares it to be properly faded later.
 */
function hide(element) {
	var elem = document.getElementById(element);
	elem.style.visibility = "hidden";
	elem.style.opacity = 0;
}

function slideIn(element,direction) {
	var elem = document.getElementById(element);
	var slideDistance = Math.max(window.innerWidth,window.innerHeight);
	direction *= 2 * Math.PI / 360;
	var fraction = 1;
	elem.style.left = "" + slideDistance * Math.cos(direction) + "px";
	elem.style.top = "" + slideDistance * Math.sin(direction) + "px";
	elem.style.opacity = 1;
	elem.style.filter = "alpha(opacity=1)"; //Legacy browsers.
	elem.style.visibility = "visible"; //Start rendering.
	var timer = setInterval(function() {
		if(fraction <= 0) { //Termination criterium.
			clearInterval(timer);
		}
		elem.style.left = "" + slideDistance * fraction * Math.cos(direction) + "px";
		elem.style.top = "" + slideDistance * fraction * Math.sin(direction) + "px";
		fraction -= (0.1 + fraction) * 0.1; //First transitions fast, then slows down towards minimum fraction.
		if(fraction <= 0) fraction = 0; //Don't go past 0.
	},10); //Execute this every 10ms.
}

function slideTo(element,tox,toy) {
	var elem = document.getElementById(element);
	//Note: Left and Top style elements MUST be in percentages!
	var startx = parseFloat(elem.style.marginLeft.substring(0, elem.style.marginLeft.length - 1)); //Parse the style as float.
	var starty = parseFloat(elem.style.marginTop.substring(0, elem.style.marginTop.length - 1));
	var fraction = 0;
	var diffx = tox - startx;
	var diffy = toy - starty;
	var timer = setInterval(function() {
		if(fraction >= 1) { //Termination criterium.
			clearInterval(timer);
		}
		elem.style.marginLeft = "" + (startx + fraction * diffx) + "%";
		elem.style.marginTop = "" + (starty + fraction * diffy) + "%";
		fraction += (1.1 - fraction) * 0.1; //First transitions fast, then slows down towards maximum fraction.
		if(fraction >= 1) fraction = 1; //Don't go past 1.
	},10); //Execute this every 10ms.
}

function moveTo(element,tox,toy) {
	var elem = document.getElementById(element);
	//Note: Left and Top style elements MUST be in percentages!
	elem.style.marginLeft = "" + tox + "%";
	elem.style.marginTop = "" + toy + "%";
}

function highLight(item_id) {
	var elem = document.getElementById("slide" + curSlide + "item" + item_id);
	elem.classList.add("highlight");
}

function unHighLight(item_id) {
	var elem = document.getElementById("slide" + curSlide + "item" + item_id);
	elem.classList.remove("highlight");
}