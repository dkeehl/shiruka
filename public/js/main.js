document.addEventListener("DOMContentLoaded", initialize, false);

function initialize() {
  bindLogin();
}

// AJAX callback function
function loadDoc(url, cFunction) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState === 4 && this.status === 200) {
      cFunction(this);
    } else if (this.readyState === 4 && this.status === 401) {
      showElement("login-form");
    }
  };

  xhttp.open("GET", url, true);
  xhttp.send();
}

// Upvote and Downvote answers
function upvote(id) {
  var url = "/answer/" + id + "/upvote";
  loadDoc(url, vote(id, "upvote"));
} 
function unvote(id) {
  var url = "/answer/" + id + "/unvote";
  loadDoc(url, vote(id, "unvote"));
}

function downvote(id) {
  var url = "/answer/" + id + "/downvote";
  loadDoc(url, vote(id, "downvote"));
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

function showResult(str) {
  if (str.length === 0) {
    document.getElementById("livesearch").innerHTML="";
    document.getElementById("livesearch").style.border="0px";
    return;
  }

  xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState === 4 &&
        this.status === 200 &&
        this.responseText.length > 0) {

      var hintList = document.getElementById("livesearch");
      hintList.innerHTML = this.responseText;
      hintList.style.border = "1px solid #A5ACB2";

      var topics = document.getElementsByClassName("auto-complete-row");
      for (i = 0; i < topics.length; i++) {
        topics[i].addEventListener("click", function(){ addTopic(this.title); });
      }
    }
  }

  xmlhttp.open("GET", "/search_topic?q=" + str, true);
  xmlhttp.send();
}

function addTopic(topic) {
  document.getElementById("topic-search-box").value = topic;
}

function showTagEditor() {
  showElement("tag_editor");
  var buttons = document.getElementsByClassName("tag-editor-remove-button");
  for (i = 0; i < buttons.length; i++) {
    if (buttons[i].style.visibility === "visible") {
      buttons[i].style.visibility = "hidden";
    } else {
      buttons[i].style.visibility = "visible";
    }
  }
}

function deleteContent(type, id) {
  var confirmBox = document.getElementById("modal");
  confirmBox.style.display = "block";
  var form = confirmBox.querySelector('form');
  form.setAttribute('action', `/${type}/${id}/delete`);  
}

