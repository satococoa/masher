$(document).ready(function () {
  function init() {
    if (localStorage["keyword"]) {
      $('#keyword').val(localStorage["keyword"]);
    }
  }

  $('.localStore').keyup(function () {
    localStorage[$(this).attr('id')] = $(this).val();
  });
  init();
});
var storekey = localStorage["keyword"];
console.log(storekey);
