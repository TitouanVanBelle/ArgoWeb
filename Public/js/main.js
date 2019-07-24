function filterTranslationsLists()
{
  var languageSelect = document.getElementById("language_filter");
  var languageId = languageSelect.options[languageSelect.selectedIndex].value;

  var packageSelect = document.getElementById("package_filter");
  var packageId = packageSelect.options[packageSelect.selectedIndex].value;

  var params = [];

  if (packageId != 0) {
    params.push("package=" + packageId);
  }

  if (languageId != 0) {
    params.push("language=" + languageId);
  }

  window.location.search = params.join("&");
}

$(document).ready(function() {
  var lastTr = function() {
    var trs = $('table tr');
    return trs[trs.length - 2];
  };

  var addRow = function() {
    var newTrHTML = lastTr().outerHTML;
    var tr = $('.add-row').parents('tr');
    tr.before(newTrHTML);
    $(lastTr).children('td').each(function (i, td) {
      $(td).children('input').val('');
    });
  };

  $('table').on('click', '.btn-wordreference', function(e) {
    var link = $(this).attr('data-link');
    var win = window.open(link, '_blank');
    if (win) {
        win.focus();
    } else {
        alert('Please allow popups for this website');
    }
    e.preventDefault();
  });

  $('table').on('click', '.delete-row', function() {
    $(this).parents("tr").remove();
  });

  var shiftPressed = false;

  $("table").on('keyup', 'input[type=text]', function(e) {
    var keyCode = e.keyCode || e.which;

    if (keyCode == 16) {
      shiftPressed = false;
    }
  });

  $("table").on('keydown', 'input[type=text]', function(e) {
    var keyCode = e.keyCode || e.which;

    if (keyCode == 16) {
      shiftPressed = true;
    }

    if (keyCode != 9 || shiftPressed) {
      return;
    }

    var trs = $('table tr');
    var lastTr = trs[trs.length - 2];
    var tr = $(this).parents('tr')[0];

    if (tr == lastTr) {
      addRow();
    }
  });

  $(".add-row").click(addRow);
});
