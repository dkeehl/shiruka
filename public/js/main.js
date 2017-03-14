document.addEventListener("DOMContentLoaded", initialize, false);

function initialize() {
  bindLogin();
}

// AJAX callback function
function getAjax(url, cFunction) {
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (this.readyState === 4 && this.status === 200) {
      cFunction(this);
    } else if (this.readyState === 4 && this.status === 401) {
      showElement("login-form");
    }
  };

  xhr.open("GET", url, true);
  xhr.send();
}

// AJAX post
function postAjax(url, data, success) {
  var params = typeof data == 'string' ? data : Object.keys(data).map(
    function(k) { return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]) }
  ).join('&');

  var xhr = new XMLHttpRequest();
  xhr.open('POST', url);
  xhr.onreadystatechange = function() {
    if (this.readyState > 3 && this.status === 200) { success(this); }
  };

  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  xhr.send(params);
  return xhr;
}


// Upvote and Downvote answers
function upvote(id) {
  var url = "/answer/" + id + "/upvote";
  getAjax(url, vote(id, "upvote"));
} 
function unvote(id) {
  var url = "/answer/" + id + "/unvote";
  getAjax(url, vote(id, "unvote"));
}

function downvote(id) {
  var url = "/answer/" + id + "/downvote";
  getAjax(url, vote(id, "downvote"));
}

var up_arrow_pressed = { pressed:"true", action:"unvote", text:"取消赞同" };
var up_arrow = { pressed:"false", action:"upvote", text:"赞同" };
var down_arrow_pressed = { pressed:"true", action:"unvote", text:"取消反对" };
var down_arrow = { pressed:"false", action:"downvote", text:"反对，不会显示你的名字" };

function set_arrow_state(button, state) {
  var id = /\d+/.exec(button.getAttribute("onclick"));
  button.setAttribute("aria-pressed", state.pressed);
  button.setAttribute("onclick", state.action + "(" + id + ")");
  button.setAttribute("title", state.text);
}

function vote(id, vote_type) {
  return function(xhttp) {
    var itemAnswer = document.getElementById("item-answer-" + id);
    var button_up = itemAnswer.getElementsByClassName("up")[0];
    var button_down = itemAnswer.getElementsByClassName("down")[0];
    switch(vote_type) {
      case "unvote":
        set_arrow_state(button_up, up_arrow);
        set_arrow_state(button_down, down_arrow);
        break;
      case "upvote":
        set_arrow_state(button_up, up_arrow_pressed);
        set_arrow_state(button_down, down_arrow);
        break;
      case "downvote":
        set_arrow_state(button_up, up_arrow);
        set_arrow_state(button_down, down_arrow_pressed);
    }
    itemAnswer.querySelectorAll("span.count")[0].innerHTML = xhttp.responseText;
  }
}

// login
function bindLogin() {
  var form = document.getElementById("js-login-form");
  function sendData() {
    var form_data = new FormData(form);
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState === 4 && this.status === 200) {
        window.location.assign(this.responseURL);
      } else if (this.readyState === 4 && this.status === 401) {
        var lbl = document.querySelector(".login-form-inner label.error");
        lbl.setAttribute("class", "error is-visible");
      }
    };
    xhttp.open("POST", "/login");
    xhttp.send(form_data);
  }
  form.addEventListener("submit", function(event) {
    event.preventDefault();
    sendData();
  });
}

// show-hiding elements
function showElement(id) {
  var x = document.getElementById(id);
  if (x.style.display === "block") {
   x.style.display = "none";
  } else {
    x.style.display = "block";
  }
}

function deleteContent(type, id) {
  var confirmBox = document.getElementById("modal");
  confirmBox.style.display = "block";
  var form = confirmBox.querySelector('form');
  form.setAttribute('action', `/${type}/${id}/delete`);  
}

