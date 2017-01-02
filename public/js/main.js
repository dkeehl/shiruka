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
  confirmBox = document.getElementById("modal")
  confirmBox.style.display = "block"
  confirmBox.innerHTML = "\
  <div class='container'> \
    <p>确认删除？</p> \
    <form action='/" + type + "/" + id + "' method='post'> \
      <input type='hidden' name='_method' value='delete'> \
      <input type='submit' value='删除'> \
      <button type='button' onclick='document.getElementById(\"modal\").style.display = \"none\"'>取消</button> \
    </form> \
  </div>"
}

window.onload = function() {
  var x = document.getElementById("edit_tags");
  x.addEventListener("click", showTagEditor);
}
