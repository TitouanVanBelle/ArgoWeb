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
