function filterPackages()
{
  var languageSelect = document.getElementById("language_filter");
  var languageId = languageSelect.options[languageSelect.selectedIndex].value;

  var themeSelect = document.getElementById("theme_filter");
  var themeId = themeSelect.options[themeSelect.selectedIndex].value;

  var params = [];

  if (themeId != 0) {
    params.push("theme=" + themeId);
  }

  if (languageId != 0) {
    params.push("language=" + languageId);
  }

  window.location.search = params.join("&");
}

$(document).ready(function() {
  var addWord = function() {
    var row = '<tr><td><input type="text" name="words[]" class="form-control"><button class="btn btn-red delete-row" type="button" tabindex="-1">Remove</button></td></tr>';
    var tr = $(".add-row").parents("tr");
    tr.before(row);
  };

  $('table').on('click', '.delete-row', function() {
    $(this).parents("tr").remove();
  });

  $("table").on('keydown', 'input[type=text]', function(e) {
    var keyCode = e.keyCode || e.which;

    if (keyCode != 9) {
      return;
    }
    
    var trs = $('table tr');
    var lastTr = trs[trs.length - 2];
    var tr = $(this).parents('tr')[0];

    if (tr == lastTr) {
      addWord();
    }
  });

  $(".add-row").click(addWord);
});
