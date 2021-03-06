var Downloader = require('downloader');
var InputManager = require('./input');
var $ = require('cheerio');

// input handling
var inputMan = new InputManager();
var argv = inputMan.getArguments();

var logger = require('logger-generator')(inputMan.retrieveLoggerConfig(argv))
var downloader =  new Downloader(logger, [1000, 5000]);

function getFullUrl(el) {
  return "http://www.parliament.bg" + $(el).attr('href');
}

function scrapeSession(url, html) {
  var $content = $('#leftcontent', html)
  var stenograph = $content.find(".markcontent").text();
  var xls = [];
  var date = $content.find(".marktitle").eq(0).text().match(/\d+\/\d+\/\d+/g)[0]
             .replace(/(\d+)\/(\d+)\/(\d+)/g, function(match, d, m, y) { return [y, m, d].join("-") });
  var $links = $content.find('.frontList a');
  var $spreadsheets = $links.filter('[href$=".xls"]');

  if ($spreadsheets.length < 1) {
    logger.info("Missing XLS document(s) at: " + url)
  }

  $spreadsheets.each(function(i, el) {
    xls.push(getFullUrl(el));
  });

  console.log(JSON.stringify({
    date: date,
    xls: xls,
    url: url,
    stenograph: stenograph
  }));
}

function scrapeSessions(html) {
  $('#monthview a:contains("Пленарно заседание")', html).each(function(i, el) {
    var url = getFullUrl(el)
    downloader.get(url, function(html) {
      scrapeSession(url, html);
    });
  });
}

function scrapeMonths(html) {
  $('#calendar a', html).each(function(i, el) {
    var url = getFullUrl(el)
    downloader.get(url, scrapeSessions);
  });
}

function init() {
  downloader.get(argv.url, scrapeMonths);
}

init();

