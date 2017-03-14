//generate a modal tag editor
function genTagEditor() {
  var container = document.querySelector(".modal-container");
  var source = document.querySelector("script.tags-editor-tmp");
  container.innerHTML = source.innerHTML;
  container.style = 'display: block';
  var closeBtn = document.querySelector(".tags-editor .close");
  closeBtn.addEventListener('click', (function(c) {
    return function () {
      c.style = 'display: none';
      c.innerHTML = '';
    }})(container));
  bindTagEditor();
}

var btn = document.querySelector(".call-tag-editor");
btn.addEventListener('click', genTagEditor);

function bindTagEditor() {
  bindRemoveTag();
  bindSearch();
  bindSubmitModTag();
}

function bindRemoveTag() {
  var buttons = document.querySelectorAll('.tags [data-role="remove"]');
  for (var i = 0; i < buttons.length; i ++) {
    buttons[i].addEventListener('click', removeTag);
  }
}

function removeTag(event) {
  var tag = event.target.parentNode;
  tag.parentNode.removeChild(tag); 
}

const maxTags = 5;

function addTag(tag_id, tag_name) {
  var tags = tagsValue()
  if (!tags.includes(tag_name) && tags.length <= maxTags) {
    _addTag(tag_id, tag_name);
  }
}

function _addTag(tag_id, tag_name) {
  var list = document.querySelector('.modal-container .tags');
  var new_tag = document.createElement('div');
  var text = document.createTextNode(tag_name);
  var remove_button = document.createElement('span');

  remove_button.setAttribute('data-role', 'remove');
  new_tag.setAttribute('data', tag_id);
  new_tag.setAttribute('class', 'tag');

  new_tag.appendChild(text);
  new_tag.appendChild(remove_button);
  list.appendChild(new_tag);

  remove_button.addEventListener('click', removeTag);
}

function bindSearch() {
  var input = document.querySelector('.search-tag');
  input.addEventListener('keyup', function () { searchTag(input.value); });
}

function searchTag(key_word) {
  if (key_word.length > 0) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
      var results = [];
      if (this.readyState === 4 &&
          this.status === 200 &&
          this.responseText.length > 0) {
        results = JSON.parse(this.responseText); 
      }

      showResult(results);
    };
    
    xmlhttp.open("GET", "/search_topic?q=" + key_word, true);
    xmlhttp.send();
  } else {
    clearSearch();
  }
}

function clearSearch() {
  var result_area = document.querySelector('div.search-result');
  var input = document.querySelector('.search-tag');
  result_area.innerHTML = '';
  input.value = '';
}

function showResult(results) {
  var result_area = document.querySelector('div.search-result');
  var lis = '';
  for (var i = 0; i < results.length; i++) {
    lis = lis + `<li data="${results[i].id}">${ results[i].name }</li>\n`;
  }

  result_area.innerHTML = "<ul>\n" + lis + "</ul>\n";
  bindAddTag();
}

function bindAddTag() {
  var tags = document.querySelectorAll('.search-result li');
  for (var i = 0; i < tags.length; i++) {
    tags[i].addEventListener(
      'click',
      function (e) {
        var tag_id = e.target.getAttribute('data');
        var tag_name = e.target.innerHTML;
        addTag(tag_id, tag_name);
        clearSearch();
      }
    );
  }
}

function tagsValue() {
  var val = [];
  var tags = document.querySelectorAll('.modal-container .tag' );
  for (var i = 0; i < tags.length; i++) {
    val.push(tags[i].getAttribute('data'));
  }
  return val;
}

function submitModTag() {
  var tags = document.querySelector('.modal-container .tags');
  var questionId = tags.getAttribute('data');
  var url = '/question/' + questionId + '/modify-topics';
  var params = { 'topics' : tagsValue().join(',') };
  
  postAjax(url, params, function() {
    location.reload();
  });
}

function bindSubmitModTag() {
  var submitButton = document.querySelector('.tags-editor .save-button');
  submitButton.addEventListener('click', submitModTag);
}


