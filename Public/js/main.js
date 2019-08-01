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
  var lastTr = function(table) {
    var trs = $(table).find('tr');
    return trs[trs.length - 1];
  };

  var addRow = function() {
    $('table table').each(function() {
      var newTrHTML = lastTr(this).outerHTML;
      $(this).append(newTrHTML);
      $(lastTr(this)).find('input').val('');
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

    var trs = $('table table').first().find('tr');
    var lastTr = trs[trs.length - 1];
    var tr = $(this).parents('tr')[0];

    if (tr == lastTr) {
      addRow();
    }
  });

  $(".add-row").click(addRow);
  $('table table').on('click', '.delete-row', function() {
    var tr = $(this).parent().parent();
    var trs = $('table table').last().find('tr');
    if (trs.length <= 2) {
      return;
    }

    var index = trs.index(tr);
    $('table table').each(function() {
      $(this).find('tr')[index].remove();
    });
  });

  var translate = function() {
    var words = $("table table").first().find('input').map(function(index, input) {
      return input.value
    });

    $("table table").each(function(indexA, table) {
      if (indexA == 0) {
        return;
      }

      var key = $('#yandex-api-key').data('api-key');
      var lang = $(table).data('lang');
      $(table).find("input").each(function(indexB, input) {
        var text = words[indexB];
        $.post( "https://translate.yandex.net/api/v1.5/tr.json/translate", { key: key, text: text, lang: lang })
        .done(function(data) {
            input.value = data.text[0];
        });
      });
    });
  };

  $("#translate").click(translate);
});
